from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from database import engine, Base, get_db
import models
import schemas
import crud

# Tự động tạo bảng trong cơ sở dữ liệu SQLite
Base.metadata.create_all(bind=engine)


app = FastAPI(title="ECOFOOD API", version="1.0.0")

# Cấu hình CORS cho phép Flutter Web gọi API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Cho phép tất cả các nguồn gọi tới
    allow_credentials=True,
    allow_methods=["*"],  # Cho phép mọi phương thức (GET, POST,...)
    allow_headers=["*"],  # Cho phép mọi header
)
# API lấy danh sách thực phẩm (GET)
@app.get("/items/", response_model=list[schemas.FoodItemResponse])
def read_food_items(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    items = crud.get_food_items(db, skip=skip, limit=limit)
    return items

# API thêm mới thực phẩm (POST)
@app.post("/items/", response_model=schemas.FoodItemResponse)
def create_food_item(item: schemas.FoodItemCreate, db: Session = Depends(get_db)):
    return crud.create_food_item(db=db, item=item)

# Api Test
@app.get("/")
def read_root():
    return {"message": "Welcome to ECOFOOD API!"}