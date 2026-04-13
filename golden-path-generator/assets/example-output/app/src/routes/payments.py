"""Payment resource routes."""

import structlog
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from uuid import uuid4
from datetime import datetime

logger = structlog.get_logger()
router = APIRouter()


class PaymentRequest(BaseModel):
    """Inbound payment request schema."""
    amount: float = Field(..., gt=0, description="Payment amount in dollars")
    currency: str = Field(default="USD", pattern="^[A-Z]{3}$")
    description: str = Field(..., max_length=500)


class PaymentResponse(BaseModel):
    """Payment response schema."""
    payment_id: str
    amount: float
    currency: str
    status: str
    created_at: str


@router.post("/payments", response_model=PaymentResponse, status_code=201)
async def create_payment(request: PaymentRequest):
    """Create a new payment."""
    payment_id = str(uuid4())

    logger.info(
        "payment_created",
        payment_id=payment_id,
        amount=request.amount,
        currency=request.currency,
    )

    # Placeholder: persist to database via service layer
    return PaymentResponse(
        payment_id=payment_id,
        amount=request.amount,
        currency=request.currency,
        status="pending",
        created_at=datetime.utcnow().isoformat(),
    )


@router.get("/payments/{payment_id}", response_model=PaymentResponse)
async def get_payment(payment_id: str):
    """Retrieve a payment by ID."""
    logger.info("payment_retrieved", payment_id=payment_id)

    # Placeholder: fetch from database via service layer
    raise HTTPException(status_code=404, detail="Payment not found")
