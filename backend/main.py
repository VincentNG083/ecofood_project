from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Cấu hình CORS cho phép Flutter Web gọi API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Cho phép tất cả các nguồn gọi tới
    allow_credentials=True,
    allow_methods=["*"],  # Cho phép mọi phương thức (GET, POST,...)
    allow_headers=["*"],  # Cho phép mọi header
)

@app.get("/")
def read_root():
    return {"message": "Welcome to ECOFOOD API!"}