# CycleAI — AI-Based Menstrual Health System

A patent-oriented BTech final year project targeting rural menstrual health in India.

## What This Is

CycleAI is a comprehensive menstrual health platform combining:
- AI-driven cycle prediction (LSTM model)
- Clinically validated symptom logging (expert consultation with gynecologist)
- RAG-based medical chatbot with safety filters
- ASHA worker community health dashboard
- Offline-first architecture for low-connectivity rural deployment
- IoT-enabled smart incinerator integration

## Technical Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter / Dart |
| State Management | BLoC Pattern |
| Local Storage | SQLite (offline-first) |
| Backend API | FastAPI + PostgreSQL |
| Authentication | Firebase Auth |
| AI/ML | TensorFlow LSTM |
| Chatbot | RAG + ChromaDB + LangChain |
| IoT | ESP32 + MQTT |

## Architecture

Clean Architecture with three layers per feature:
- **Presentation** — BLoC + Pages + Widgets
- **Domain** — Entities + Use Cases + Repository interfaces  
- **Data** — Models + DataSources + Repository implementations

## Clinical Validation

Symptom taxonomy and clinical thresholds validated through expert consultation
with a practicing gynecologist. Includes:
- 13-symptom taxonomy with functional impact severity scale
- Dysmenorrhea classification (spasmodic vs congestive)
- PCOS indicator patterns
- Red-flag criteria for medical referral

## Build Status

| Phase | Feature | Status |
|---|---|---|
| 1 | Flutter Foundation + Clean Architecture | ✅ Complete |
| 2 | Firebase Authentication | ✅ Complete |
| 3 | SQLite Offline Storage | ✅ Complete |
| 4 | Period Tracking Module | ✅ Complete |
| 5 | Symptom Logging Module | ✅ Complete |
| 6 | FastAPI Backend | ✅ Complete |
| 7 | Flutter-FastAPI Sync Engine | ✅ Complete |
| 8 | ASHA Worker Dashboard | ✅ Complete |
| 9 | LSTM Cycle Prediction | 🔄 In Progress |
| 10 | Prediction API | ⬜ Planned |
| 11 | RAG Chatbot | ⬜ Planned |
| 12 | Medical Safety Filter | ⬜ Planned |

## Research

A parallel research paper is in progress targeting IEEE HEALTHCOM.
Clinical consultation documentation available in the research repository.

## Author

Neerada M Dathan  
BTech AI & Data Science 
