from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from database import Base


class Food(Base):
    __tablename__ = "foods"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    aliases = Column(String, nullable=True)
    category = Column(String, index=True, nullable=False)
    thumbnail_url = Column(String, nullable=True)

    methods = relationship(
        "PreservationMethod",
        back_populates="food",
        cascade="all, delete-orphan",
    )


class PreservationMethod(Base):
    __tablename__ = "preservation_methods"

    id = Column(Integer, primary_key=True, index=True)
    food_id = Column(Integer, ForeignKey("foods.id"), nullable=False)
    method_label = Column(String, nullable=False)       # VD: "Ngăn mát (ngắn ngày)"
    storage_zone = Column(String, nullable=False)       # VD: "Ngăn mát"
    shelf_life_text = Column(String, nullable=False)    # VD: "1 - 2 ngày"
    is_default = Column(Boolean, default=False)
    steps_json = Column(Text, nullable=False)           # JSON list các bước + ảnh/video

    food = relationship("Food", back_populates="methods")