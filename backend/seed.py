import crud
import models
import schemas
from database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

REAL_FOOD_DATA = [
    schemas.FoodCreate(
        name="Thịt ba chỉ heo",
        aliases="thịt ba rọi, thịt lợn, pork belly",
        category="Thịt cá",
        thumbnail_url="https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500",
        methods=[
            schemas.PreservationMethodCreate(
                method_label="Ngăn mát (ngắn ngày)",
                storage_zone="Ngăn mát (0°C - 4°C)",
                shelf_life_text="1 - 2 ngày",
                is_default=True,
                steps=[
                    schemas.PreservationStep(
                        step_number=1,
                        instruction="Dùng khăn giấy sạch thấm khô hoàn toàn nước và máu thừa trên bề mặt miếng thịt (không rửa lại bằng nước lã nếu chưa nấu ngay).",
                        image_url="https://images.unsplash.com/photo-1588168333986-5078d3ae3976?w=600",
                    ),
                    schemas.PreservationStep(
                        step_number=2,
                        instruction="Quấn kín miếng thịt bằng 2 lớp màng bọc thực phẩm hoặc đặt vào hộp thủy tinh có nắp đậy kín khí.",
                        image_url="https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=600",
                    ),
                    schemas.PreservationStep(
                        step_number=3,
                        instruction="Đặt ở ngăn dưới cùng của ngăn mát (nơi có nhiệt độ lạnh sâu nhất) và tách riêng khỏi rau ăn sống.",
                    ),
                ],
            ),
            schemas.PreservationMethodCreate(
                method_label="Ngăn đông (dài ngày)",
                storage_zone="Ngăn đông (-18°C)",
                shelf_life_text="30 - 45 ngày",
                is_default=False,
                steps=[
                    schemas.PreservationStep(
                        step_number=1,
                        instruction="Cắt thịt thành từng phần vừa đủ cho 1 bữa ăn để tránh phải rã đông nhiều lần làm mất chất.",
                    ),
                    schemas.PreservationStep(
                        step_number=2,
                        instruction="Bọc kín bằng màng bọc thực phẩm, cho vào túi zip ép hết không khí ra ngoài và ghi chú ngày cấp đông.",
                    ),
                ],
            ),
        ],
    ),
    schemas.FoodCreate(
        name="Rau muống",
        aliases="rau muống nước, rau muống hạt, water spinach",
        category="Rau củ",
        thumbnail_url="https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500",
        methods=[
            schemas.PreservationMethodCreate(
                method_label="Ngăn mát bọc giấy hút ẩm",
                storage_zone="Ngăn mát rau củ (5°C - 8°C)",
                shelf_life_text="3 - 4 ngày",
                is_default=True,
                steps=[
                    schemas.PreservationStep(
                        step_number=1,
                        instruction="Nhặt bỏ lá vàng, lá sâu nhưng tuyệt đối KHÔNG rửa rau trước khi cho vào tủ lạnh để tránh đọng nước gây úng.",
                        image_url="https://images.unsplash.com/photo-1518843875459-f738682238a6?w=600",
                    ),
                    schemas.PreservationStep(
                        step_number=2,
                        instruction="Dùng giấy báo hoặc khăn giấy khô quấn quanh bó rau để hút ẩm dư thừa, sau đó cho vào túi nilon đục vài lỗ thoáng khí.",
                    ),
                    schemas.PreservationStep(
                        step_number=3,
                        instruction="Đặt nhẹ nhàng vào hộc đựng rau củ ở đáy tủ lạnh, tránh để vật nặng đè lên làm dập lá.",
                    ),
                ],
            ),
        ],
    ),
    schemas.FoodCreate(
        name="Cà rốt",
        aliases="củ cải đỏ, carrot",
        category="Rau củ",
        thumbnail_url="https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500",
        methods=[
            schemas.PreservationMethodCreate(
                method_label="Ngăn mát (cắt cuống)",
                storage_zone="Ngăn mát (2°C - 5°C)",
                shelf_life_text="2 - 3 tuần",
                is_default=True,
                steps=[
                    schemas.PreservationStep(
                        step_number=1,
                        instruction="Cắt bỏ phần cuống lá xanh sát đầu củ vì phần cuống sẽ hút ngược độ ẩm làm củ nhanh mềm héo.",
                        image_url="https://images.unsplash.com/photo-1447175008436-054170c2e979?w=600",
                    ),
                    schemas.PreservationStep(
                        step_number=2,
                        instruction="Lau sạch đất bám bằng khăn khô (không rửa nước), bọc từng củ bằng giấy ăn rồi cho vào túi zip để ngăn mát.",
                    ),
                ],
            ),
            schemas.PreservationMethodCreate(
                method_label="Ngăn đông (chần sơ)",
                storage_zone="Ngăn đông (-18°C)",
                shelf_life_text="3 - 6 tháng",
                is_default=False,
                steps=[
                    schemas.PreservationStep(
                        step_number=1,
                        instruction="Gọt vỏ, thái hạt lựu hoặc khoanh tròn rồi chần qua nước sôi 2 phút, vớt ngay vào tô nước đá lạnh.",
                    ),
                    schemas.PreservationStep(
                        step_number=2,
                        instruction="Để thật ráo nước, dàn đều vào túi zip ép hết khí và bảo quản trong ngăn đông.",
                    ),
                ],
            ),
        ],
    ),
    schemas.FoodCreate(
        name="Trứng gà ta",
        aliases="trứng gà, trứng vịt, egg",
        category="Sữa & Trứng",
        thumbnail_url="https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=500",
        methods=[
            schemas.PreservationMethodCreate(
                method_label="Ngăn mát (đầu to hướng lên)",
                storage_zone="Ngăn mát (3°C - 5°C)",
                shelf_life_text="3 - 4 tuần",
                is_default=True,
                steps=[
                    schemas.PreservationStep(
                        step_number=1,
                        instruction="Không rửa trứng bằng nước trước khi cất vì sẽ làm mất lớp màng bảo vệ tự nhiên chống vi khuẩn trên vỏ trứng.",
                        image_url="https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=600",
                    ),
                    schemas.PreservationStep(
                        step_number=2,
                        instruction="Xếp trứng vào khay sao cho ĐẦU TO HƯỚNG LÊN TRÊN, đầu nhọn hướng xuống dưới để giữ túi khí ổn định.",
                    ),
                    schemas.PreservationStep(
                        step_number=3,
                        instruction="Đặt khay trứng ở kệ giữa bên trong ngăn mát thay vì cánh cửa tủ để tránh sốc nhiệt khi đóng mở.",
                    ),
                ],
            ),
        ],
    ),
    schemas.FoodCreate(
        name="Cá hồi phi lê",
        aliases="cá hồi, salmon",
        category="Thịt cá",
        thumbnail_url="https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?w=500",
        methods=[
            schemas.PreservationMethodCreate(
                method_label="Ngăn mát (dùng trong ngày)",
                storage_zone="Ngăn đông mềm / Ngăn mát sâu (0°C - 2°C)",
                shelf_life_text="1 - 2 ngày",
                is_default=True,
                steps=[
                    schemas.PreservationStep(
                        step_number=1,
                        instruction="Dùng khăn giấy thấm khô bề mặt miếng cá, bọc kín bằng màng bọc thực phẩm để tránh ám mùi sang thực phẩm khác.",
                    ),
                    schemas.PreservationStep(
                        step_number=2,
                        instruction="Đặt hộp cá lên trên một khay đá viên nhỏ bên trong ngăn mát để giữ nhiệt độ luôn sát 0°C.",
                    ),
                ],
            ),
            schemas.PreservationMethodCreate(
                method_label="Ngăn đông (hút chân không)",
                storage_zone="Ngăn đông (-18°C)",
                shelf_life_text="2 - 3 tháng",
                is_default=False,
                steps=[
                    schemas.PreservationStep(
                        step_number=1,
                        instruction="Bọc chặt từng lát cá bằng màng bọc thực phẩm, sau đó cho vào túi zip hút chân không.",
                    ),
                    schemas.PreservationStep(
                        step_number=2,
                        instruction="Khi dùng, chuyển cá xuống ngăn mát rã đông từ từ qua đêm trước khi chế biến.",
                    ),
                ],
            ),
        ],
    ),
]


def run_seed():
    db = SessionLocal()
    try:
        if db.query(models.Food).count() > 0:
            print("Database đã có dữ liệu. Bỏ qua bước nạp mẫu.")
            return
        for item in REAL_FOOD_DATA:
            crud.create_food_with_methods(db=db, food_in=item)
        print(f"Đã nạp thành công {len(REAL_FOOD_DATA)} thực phẩm thật vào ecofood.db!")
    finally:
        db.close()


if __name__ == "__main__":
    run_seed()