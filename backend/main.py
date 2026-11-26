import os
from typing import List, Optional

from fastapi import Depends, FastAPI, File, HTTPException, Query, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session

import crud
import models
import schemas
from ai_vision import analyze_food_image
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="ECOFOOD API", version="2.1.0")

# Phục vụ ảnh minh họa lưu cục bộ trong thư mục backend/static/images/
os.makedirs("static/images", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def health_check():
    return {"status": "ok", "app": "ECOFOOD", "version": "2.1.0"}


@app.post("/foods/", response_model=schemas.FoodResponse, status_code=201)
def create_food(food_in: schemas.FoodCreate, db: Session = Depends(get_db)):
    return crud.create_food_with_methods(db=db, food_in=food_in)


@app.get("/foods/", response_model=List[schemas.FoodResponse])
def list_foods(
    q: Optional[str] = Query(default=None, description="Từ khóa tìm theo tên hoặc alias"),
    category: Optional[str] = Query(default=None, description="Lọc theo danh mục thực phẩm"),
    db: Session = Depends(get_db),
):
    return crud.search_foods(db=db, query=q, category=category)


@app.get("/foods/{food_id}", response_model=schemas.FoodResponse)
def get_food(food_id: int, db: Session = Depends(get_db)):
    food = crud.get_food_by_id(db=db, food_id=food_id)
    if not food:
        raise HTTPException(status_code=404, detail="Không tìm thấy thực phẩm")
    return food


@app.post("/detect-table")
async def detect_table_foods(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    image_bytes = await file.read()
    known_foods = [f.name for f in db.query(models.Food).all()]
    try:
        items = analyze_food_image(
            image_bytes=image_bytes,
            mime_type=file.content_type or "image/jpeg",
            known_foods=known_foods,
            is_receipt=False,
        )
        return {"items": items}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi nhận diện bàn thực phẩm: {str(e)}")


@app.post("/ocr/scan")
async def scan_receipt_foods(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    image_bytes = await file.read()
    known_foods = [f.name for f in db.query(models.Food).all()]
    try:
        items = analyze_food_image(
            image_bytes=image_bytes,
            mime_type=file.content_type or "image/jpeg",
            known_foods=known_foods,
            is_receipt=True,
        )
        return {"items": items}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi quét hóa đơn: {str(e)}")