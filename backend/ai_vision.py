import os
from typing import List
from dotenv import load_dotenv
from pydantic import BaseModel
from google import genai
from google.genai import types

load_dotenv()  # Tự động nạp biến GEMINI_API_KEY từ tệp backend/.env


class DetectedFoodResponse(BaseModel):
    items: List[str]


def analyze_food_image(
    image_bytes: bytes,
    mime_type: str,
    known_foods: List[str],
    is_receipt: bool = False,
) -> List[str]:
    # Dòng này sẽ tự động lấy đúng mã key bạn đã dán trong tệp .env
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("Server chưa cấu hình biến môi trường GEMINI_API_KEY")


class DetectedFoodResponse(BaseModel):
    items: List[str]


def analyze_food_image(
    image_bytes: bytes,
    mime_type: str,
    known_foods: List[str],
    is_receipt: bool = False,
) -> List[str]:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("Server chưa cấu hình biến môi trường GEMINI_API_KEY")

    client = genai.Client(api_key=api_key)
    known_str = ", ".join(known_foods) if known_foods else "Chưa có dữ liệu"

    if is_receipt:
        prompt = (
            "Đây là ảnh chụp hóa đơn mua hàng. Hãy đọc toàn bộ chữ trên hóa đơn và "
            "lọc ra CHỈ CÁC MẶT HÀNG LÀ THỰC PHẨM TƯƠI SỐNG HOẶC NGUYÊN LIỆU NẤU ĂN "
            "(bỏ qua túi nilon, gia vị đóng chai, đồ gia dụng, số lượng và giá tiền). "
            f"Nếu tên thực phẩm gần nghĩa với danh sách sau thì bắt buộc dùng đúng tên trong danh sách: [{known_str}]. "
            "Nếu chưa có trong danh sách, trả về tên tiếng Việt ngắn gọn, chuẩn xác."
        )
    else:
        prompt = (
            "Đây là ảnh chụp bàn hoặc rổ chứa các loại thực phẩm cần bảo quản. "
            "Hãy quan sát kỹ toàn bộ khung hình và liệt kê tất cả thực phẩm nhận diện được. "
            f"Nếu thực phẩm nhìn thấy khớp với danh sách sau thì bắt buộc dùng đúng tên trong danh sách: [{known_str}]. "
            "Nếu chưa có trong danh sách, đặt tên tiếng Việt phổ biến, ngắn gọn (VD: 'Thịt ba chỉ heo', 'Rau muống')."
        )

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=[
            types.Part.from_bytes(
                data=image_bytes,
                mime_type=mime_type or "image/jpeg",
            ),
            prompt,
        ],
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=DetectedFoodResponse,
            temperature=0.1,
        ),
    )

    if response.parsed:
        return response.parsed.items
    return []