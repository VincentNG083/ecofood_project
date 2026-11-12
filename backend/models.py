from sqlalchemy import Column, Integer, String, Float, Date
from database import Base

class FoodItemModel(Base):
    __tablename__ = "food_items"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, index=True, nullable=False)
    category = Column(String, nullable=False)
    quantity = Column(Float, nullable=False)
    unit = Column(String, nullable=False)
    expiry_date = Column(Date, nullable=False)
    storage_zone = Column(String, nullable=False)  # Ngăn mát, Ngăn đông, Tủ khô


class StorageZoneModel(Base):
    __tablename__ = "storage_zones"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, unique=True, index=True, nullable=False)
    description = Column(String, nullable=True)