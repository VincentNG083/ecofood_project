from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date

# 1. Mô hình cho Thực phẩm (Food Item)
class FoodItemBase(BaseModel):
    name: str = Field(..., description="Tên thực phẩm, ví dụ: Thịt bò, Sữa tươi")
    category: str = Field(..., description="Phân loại: Rau củ, Thịt cá, Đồ hộp, Sữa...")
    quantity: float = Field(..., gt=0, description="Số lượng hoặc trọng lượng")
    unit: str = Field(..., description="Đơn vị tính: kg, gram, hộp, quả, ml...")
    expiry_date: date = Field(..., description="Ngày hết hạn (YYYY-MM-DD)")
    storage_zone: str = Field(..., description="Vùng lưu trữ: Tủ lạnh (Ngăn mát), Ngăn đông, Tủ khô")

class FoodItemCreate(FoodItemBase):
    """Dữ liệu client gửi lên khi thêm mới một loại thực phẩm"""
    pass

class FoodItemResponse(FoodItemBase):
    """Dữ liệu trả về cho client kèm theo ID định danh từ database"""
    id: int

    class Config:
        from_attributes = True


# 2. Mô hình cho Vùng lưu trữ (Storage Zone) - Dùng để quản lý 3 vùng
class StorageZoneBase(BaseModel):
    name: str = Field(..., description="Tên vùng: Ngăn mát, Ngăn đông, Tủ khô")
    description: Optional[str] = Field(None, description="Mô tả chi tiết hoặc nhiệt độ khuyến nghị")

class StorageZoneResponse(StorageZoneBase):
    id: int
    items_count: int = Field(0, description="Số lượng thực phẩm đang có trong vùng này")

    class Config:
        from_attributes = True


# 3. Mô hình cho kết quả quét hóa đơn (OCR Receipt Scanner)
class ReceiptScanResponse(BaseModel):
    extracted_text: str = Field(..., description="Văn bản thô đọc được từ hóa đơn")
    suggested_items: List[FoodItemCreate] = Field(..., description="Danh sách thực phẩm gợi ý bóc tách tự động từ hóa đơn")