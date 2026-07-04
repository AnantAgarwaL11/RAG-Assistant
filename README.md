<p align="center">
  <h1 align="center">📄 RAG Document Assistant</h1>
  <p align="center">
    An intelligent document question-answering system powered by Retrieval-Augmented Generation (RAG).
    <br />
    Built with a <strong>Flutter</strong> mobile frontend and a <strong>Python FastAPI</strong> backend.
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/FastAPI-0.100+-009688?logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/LangChain-🦜-green" alt="LangChain" />
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License" />
</p>

---

## 📖 Overview

**RAG Document Assistant** is a full-stack application that lets you upload documents (PDFs, Word files, PowerPoints, images, and text files), processes them into vector embeddings, and enables you to ask natural language questions about their content. The system retrieves relevant context from your documents and generates accurate, grounded answers using a large language model.

### How It Works

```
┌──────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter App  │────▶│  FastAPI Backend  │────▶│   RAG Pipeline  │
│  (Frontend)   │◀────│    (REST API)     │◀────│                 │
└──────────────┘     └──────────────────┘     │  ┌───────────┐  │
                                               │  │ Doc       │  │
                                               │  │ Processor │  │
                                               │  ├───────────┤  │
                                               │  │ Vector    │  │
                                               │  │ Store     │  │
                                               │  ├───────────┤  │
                                               │  │ LLM       │  │
                                               │  │ Manager   │  │
                                               │  └───────────┘  │
                                               └─────────────────┘
```

1. **Upload** — Documents are uploaded via the Flutter app and sent to the FastAPI backend.
2. **Process** — The backend extracts text, tables, and images (via OCR), then splits content into chunks.
3. **Embed** — Chunks are converted into vector embeddings and stored in FAISS or ChromaDB.
4. **Query** — When you ask a question, the system retrieves the most relevant chunks and feeds them as context to an LLM, which generates a grounded answer.

---

## ✨ Features

### 📱 Flutter Frontend
- **Document Upload** — Pick and upload multiple files at once with progress tracking
- **Chat Interface** — Conversational Q&A over your uploaded documents
- **Document Manager** — Browse, inspect, and delete uploaded documents
- **Analytics Dashboard** — View processing stats, document counts, page totals, and chunk distributions
- **Settings Panel** — Configure backend URL, API keys, LLM model, chunk size, overlap, and batch size
- **Storage Management** — Export, import, and clear all data
- **Cross-Platform** — Runs on Android, iOS, Web, Windows, macOS, and Linux

### 🐍 Python Backend
- **Multi-Format Processing** — PDF, DOCX, DOC, PPTX, PPT, PNG, JPG, JPEG, GIF, BMP, TIFF, TXT, MD
- **Advanced PDF Extraction** — Uses `unstructured` + `pdfplumber` for comprehensive text, table, and image extraction with fallback to basic `PyPDF2`
- **OCR Support** — Tesseract-based OCR for images and scanned documents (English & German)
- **Table Extraction** — Structured table parsing from PDFs and Word documents
- **Multiple LLM Backends**:
  - **OpenAI** — GPT-3.5 Turbo, GPT-4, GPT-4 Turbo
  - **Ollama** — Any locally hosted model (Llama, Mistral, etc.)
  - **HuggingFace** — Open-source models with optional 4-bit quantization (Mistral, DialoGPT, Flan-T5, etc.)
  - **Local Models** — Load models from a local file path
- **Vector Stores** — FAISS (default) and ChromaDB with support for save/load/export/import
- **Embedding Models** — HuggingFace Sentence Transformers or OpenAI Embeddings
- **Batch Processing** — Process large document collections in configurable batches
- **Bilingual Support** — English and German language support for OCR and Q&A

---

## 🏗️ Project Structure

```
rag_document_assistant/
├── lib/                          # Flutter application source
│   ├── main.dart                 # App entry point & navigation
│   ├── models/
│   │   ├── app_config.dart       # App configuration model
│   │   ├── chat_message.dart     # Chat message model
│   │   └── document_model.dart   # Document data model
│   ├── services/
│   │   ├── chat_service.dart     # Chat state management
│   │   ├── document_service.dart # Document upload & processing
│   │   └── storage_service.dart  # Local persistence (SharedPreferences)
│   ├── widgets/
│   │   ├── upload_screen_widget.dart    # Upload UI with drag-and-drop
│   │   ├── chat_screen_widget.dart      # Chat conversation UI
│   │   ├── documents_screen_widget.dart # Document browser UI
│   │   └── analytics_screen_widget.dart # Analytics dashboard UI
│   ├── constants/
│   │   └── app_constants.dart    # App-wide constants & configuration
│   └── utils/
│       ├── file_utils.dart       # File handling utilities
│       └── permission_utils.dart # Runtime permission helpers
│
├── backend/                      # Python backend
│   ├── api.py                    # FastAPI REST API endpoints
│   ├── app.py                    # Streamlit UI (standalone)
│   ├── start_api.py              # API server launcher
│   ├── config.json               # Default pipeline configuration
│   ├── requirements.txt          # Python dependencies
│   └── src/
│       ├── document_processor.py # Multi-format document processing & OCR
│       ├── vector_store.py       # FAISS / ChromaDB vector store manager
│       ├── llm_manager.py        # Multi-provider LLM abstraction
│       ├── rag_pipeline.py       # End-to-end RAG orchestration
│       └── utils.py              # Shared utilities & directory setup
│
├── android/                      # Android platform files
├── ios/                          # iOS platform files
├── web/                          # Web platform files
├── windows/                      # Windows platform files
├── macos/                        # macOS platform files
├── linux/                        # Linux platform files
├── pubspec.yaml                  # Flutter dependencies
└── README.md                     # This file
```

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [Flutter SDK](https://flutter.dev/docs/get-started/install) | ≥ 3.8 | Mobile/web/desktop frontend |
| [Python](https://www.python.org/downloads/) | ≥ 3.10 | Backend server |
| [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) | ≥ 4.0 | Image text extraction (optional) |
| [Ollama](https://ollama.ai/) | Latest | Local LLM hosting (optional) |

### 1. Clone the Repository

```bash
git clone https://github.com/AnantAgarwaL11/RAG-Assistant.git
cd RAG-Assistant
```

### 2. Backend Setup

```bash
cd backend

# Create and activate a virtual environment
python -m venv venv

# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### Start the API Server

```bash
# Option 1: Direct
python api.py

# Option 2: Using the launcher script
python start_api.py

# Option 3: With uvicorn directly
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```

The API server will be available at `http://localhost:8000`. Visit `http://localhost:8000/docs` for the interactive Swagger UI.

#### (Optional) Streamlit UI

The backend also includes a standalone Streamlit web interface:

```bash
streamlit run app.py
```

### 3. Frontend Setup

```bash
# From the project root
flutter pub get

# Run on your desired platform
flutter run                # Default connected device
flutter run -d chrome      # Web
flutter run -d windows     # Windows desktop
flutter run -d android     # Android emulator/device
```

### 4. Connect Frontend to Backend

1. Open the app and tap the **⚙️ Settings** icon in the app bar.
2. Go to **API Configuration**.
3. Set the **Backend URL**:
   - Android Emulator → `http://10.0.2.2:8000/api`
   - iOS Simulator / Web / Desktop → `http://localhost:8000/api`
   - Physical device → `http://<your-pc-ip>:8000/api`
4. Select your preferred **Model Type** and enter an **API Key** if using OpenAI.
5. Tap **Save**.

---

## ⚙️ Configuration

### Backend Configuration (`backend/config.json`)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `model_type` | `HuggingFace Open Source` | LLM provider (`OpenAI`, `Ollama`, `HuggingFace Open Source`, `Local Model`) |
| `model_name` | `microsoft/DialoGPT-medium` | Specific model identifier |
| `embedding_model` | `sentence-transformers/distiluse-base-multilingual-cased` | Embedding model for vectorization |
| `chunk_size` | `1000` | Characters per text chunk |
| `chunk_overlap` | `100` | Overlapping characters between chunks |
| `vector_store_type` | `chroma` | Vector store backend (`faiss` or `chroma`) |
| `retrieval_k` | `10` | Number of chunks to retrieve per query |
| `max_file_size_mb` | `100` | Maximum upload file size |
| `enable_ocr` | `true` | Enable OCR for images/scanned docs |
| `language` | `deu` | Document language |
| `ocr_language` | `deu` | Tesseract OCR language |
| `batch_size` | `10` | Documents per processing batch |

### Frontend Configuration (In-App Settings)

| Setting | Default | Description |
|---------|---------|-------------|
| Backend URL | `http://10.0.2.2:8000/api` | Backend API endpoint |
| Model Type | `OpenAI GPT-3.5` | LLM selection |
| Chunk Size | `1000` | Text chunk size (500–2000) |
| Chunk Overlap | `200` | Chunk overlap (50–500) |
| Batch Size | `10` | Upload batch size (1–50) |
| Temperature | `0.7` | LLM response randomness |
| Max Tokens | `1000` | Maximum response length |

---

## 📡 API Reference

All endpoints are served from `http://localhost:8000`.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Health check |
| `GET` | `/system/stats` | System & pipeline statistics |
| `POST` | `/pipeline/initialize` | Initialize the RAG pipeline with model config |
| `GET` | `/documents` | List all processed documents |
| `POST` | `/documents/upload` | Upload and process documents (multipart) |
| `DELETE` | `/documents/{id}` | Delete a specific document |
| `POST` | `/chat` | Send a question and get an AI-generated answer |
| `GET` | `/analytics` | Get document analytics & stats |
| `GET` | `/vector-store/export` | Export vector store as `.pkl` archive |
| `POST` | `/vector-store/import` | Import a vector store archive |

### Example: Ask a Question

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What are the key findings in the report?"}'
```

### Example: Upload a Document

```bash
curl -X POST http://localhost:8000/documents/upload \
  -F "files=@/path/to/document.pdf"
```

---

## 🤖 Supported Models

### LLM Providers

| Provider | Models | Requirements |
|----------|--------|-------------|
| **OpenAI** | GPT-3.5 Turbo, GPT-4, GPT-4 Turbo | OpenAI API key |
| **Ollama** | Llama 2/3, Mistral, Mixtral, Phi, etc. | [Ollama](https://ollama.ai/) running locally |
| **HuggingFace** | DialoGPT, Mistral, Flan-T5, LLaMA, etc. | GPU recommended for larger models |
| **Local Model** | Any HuggingFace-compatible model | Model files on disk |

### Embedding Models

| Model | Use Case |
|-------|----------|
| `sentence-transformers/all-MiniLM-L6-v2` | Fast, lightweight, English |
| `sentence-transformers/distiluse-base-multilingual-cased` | Multilingual (default) |
| OpenAI Embeddings | High quality, requires API key |

---

## 📂 Supported File Formats

| Format | Extensions | Extraction Method |
|--------|------------|-------------------|
| PDF | `.pdf` | `unstructured` + `pdfplumber` (fallback: `PyPDF2`) |
| Word | `.docx`, `.doc` | `unstructured` (fallback: `docx2txt`) |
| PowerPoint | `.pptx`, `.ppt` | `unstructured` |
| Images | `.png`, `.jpg`, `.jpeg`, `.gif`, `.bmp`, `.tiff` | Tesseract OCR |
| Plain Text | `.txt`, `.md` | Direct read |

---

## 🛠️ Tech Stack

### Frontend
- **Framework:** Flutter 3.x / Dart 3.x
- **State Management:** Provider
- **HTTP Client:** `http` package
- **File Handling:** `file_picker`, `path_provider`
- **Persistence:** `shared_preferences`
- **Connectivity:** `connectivity_plus`

### Backend
- **Framework:** FastAPI + Uvicorn
- **RAG Orchestration:** LangChain
- **Vector Stores:** FAISS, ChromaDB
- **Embeddings:** Sentence Transformers, OpenAI Embeddings
- **LLMs:** OpenAI, Ollama, HuggingFace Transformers
- **Document Parsing:** `unstructured`, `pdfplumber`, `PyPDF2`, `python-docx`, `python-pptx`
- **OCR:** Tesseract (`pytesseract`) + OpenCV
- **ML Runtime:** PyTorch

---

## 🧪 Development

### Running in Development Mode

```bash
# Backend (with hot reload)
uvicorn api:app --host 0.0.0.0 --port 8000 --reload

# Frontend (with hot reload)
flutter run
```

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | If using OpenAI | Your OpenAI API key |

---

## 📝 License

This project is open-source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- [LangChain](https://github.com/langchain-ai/langchain) — RAG framework & LLM orchestration
- [FAISS](https://github.com/facebookresearch/faiss) — Efficient similarity search
- [Sentence Transformers](https://www.sbert.net/) — State-of-the-art embeddings
- [Unstructured](https://github.com/Unstructured-IO/unstructured) — Advanced document parsing
- [Flutter](https://flutter.dev/) — Cross-platform UI framework

---

<p align="center">
  Built with ❤️ by <a href="https://github.com/AnantAgarwaL11">Anant Agarwal</a>
</p>
