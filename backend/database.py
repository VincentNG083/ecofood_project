from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Đường dẫn file SQLite lưu trữ cục bộ trong thư mục backend
SQLALCHEMY_DATABASE_URL = "sqlite:///./ecofood.db"

# Khởi tạo SQLAlchemy engine cho SQLite
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# Tạo SessionLocal để tương tác với cơ sở dữ liệu trong các API request
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class để định nghĩa các mô hình bảng database sau này
Base = declarative_base()

# Hàm dependency giúp tự động mở và đóng session database cho mỗi request
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()