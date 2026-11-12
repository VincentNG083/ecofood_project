from sqlalchemy.orm import Session
import models
import schemas

def get_food_items(db: Session, skip: int = 0, limit: int = 100):
    """Lấy danh sách tất cả thực phẩm trong kho"""
    return db.query(models.FoodItemModel).offset(skip).limit(limit).all()

def create_food_item(db: Session, item: schemas.FoodItemCreate):
    """Thêm mới một loại thực phẩm vào database"""
    db_item = models.FoodItemModel(**item.model_dump())
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item