from typing import List, Optional

from fastapi import Depends, FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

import crud
import models
import schemas
from database import Base, engine, get_db

# Tạo bảng mới nếu chưa có
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="ECOFOOD API", version="2.0.0")

# Cho phép Flutter / Web gọi API cục bộ trong quá trình phát triển
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def health_check():
    return {"status": "ok", "app": "ECOFOOD", "version": "2.0.0"}


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