import json
from typing import List, Optional
from sqlalchemy.orm import Session
import models, schemas


def search_foods(db: Session, query: Optional[str] = None, category: Optional[str] = None) -> List[models.Food]:
    q = db.query(models.Food)
    if category:
        q = q.filter(models.Food.category == category)
    if query:
        pattern = f"%{query.strip()}%"
        q = q.filter(
            (models.Food.name.ilike(pattern)) | (models.Food.aliases.ilike(pattern))
        )
    return q.all()


def get_food_by_id(db: Session, food_id: int) -> Optional[models.Food]:
    return db.query(models.Food).filter(models.Food.id == food_id).first()


def create_food_with_methods(db: Session, food_in: schemas.FoodCreate) -> models.Food:
    db_food = models.Food(
        name=food_in.name,
        aliases=food_in.aliases,
        category=food_in.category,
        thumbnail_url=food_in.thumbnail_url,
    )
    db.add(db_food)
    db.flush()  # Lấy db_food.id trước khi commit

    for m in food_in.methods:
        db_method = models.PreservationMethod(
            food_id=db_food.id,
            method_label=m.method_label,
            storage_zone=m.storage_zone,
            shelf_life_text=m.shelf_life_text,
            is_default=m.is_default,
            steps_json=json.dumps([step.model_dump() for step in m.steps], ensure_ascii=False),
        )
        db.add(db_method)

    db.commit()
    db.refresh(db_food)
    return db_food