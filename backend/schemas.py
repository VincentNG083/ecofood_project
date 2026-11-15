import json
from typing import Any, List, Optional
from pydantic import BaseModel, ConfigDict, model_validator


class PreservationStep(BaseModel):
    step_number: int
    instruction: str
    image_url: Optional[str] = None
    video_url: Optional[str] = None


class PreservationMethodBase(BaseModel):
    method_label: str
    storage_zone: str
    shelf_life_text: str
    is_default: bool = False
    steps: List[PreservationStep]


class PreservationMethodCreate(PreservationMethodBase):
    pass


class PreservationMethodResponse(PreservationMethodBase):
    id: int
    food_id: int

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="before")
    @classmethod
    def parse_steps_from_db(cls, data: Any) -> Any:
        # Xử lý khi đầu vào là SQLAlchemy model object (từ DB trả về)
        if hasattr(data, "steps_json"):
            steps_raw = getattr(data, "steps_json")
            steps_parsed = json.loads(steps_raw) if steps_raw else []
            return {
                "id": data.id,
                "food_id": data.food_id,
                "method_label": data.method_label,
                "storage_zone": data.storage_zone,
                "shelf_life_text": data.shelf_life_text,
                "is_default": data.is_default,
                "steps": steps_parsed,
            }

        # Xử lý khi đầu vào là dict (ví dụ build dict thủ công)
        if isinstance(data, dict) and "steps_json" in data and "steps" not in data:
            steps_raw = data.get("steps_json")
            data = {
                **data,
                "steps": json.loads(steps_raw) if steps_raw else [],
            }

        return data


class FoodBase(BaseModel):
    name: str
    aliases: Optional[str] = None
    category: str
    thumbnail_url: Optional[str] = None


class FoodCreate(FoodBase):
    methods: List[PreservationMethodCreate] = []


class FoodResponse(FoodBase):
    id: int
    methods: List[PreservationMethodResponse] = []

    model_config = ConfigDict(from_attributes=True)