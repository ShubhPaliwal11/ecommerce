require("dotenv").config();
const express = require("express");
const cors = require("cors");
const csrf = require("csurf");
const session = require("express-session");
const cookieParser = require("cookie-parser");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const Razorpay = require("razorpay");

const app = express();
const port = process.env.PORT || 3001;

// Initialize Razorpay with your test keys
const razorpay = new Razorpay({
  key_id: "rzp_test_47mpRvV2Yh9XLZ",
  key_secret: "0je47WgWBGYVUQgpwYLpfHup",
});

// Security middleware
app.use(helmet());
app.use(express.json({ limit: "10kb" }));
app.use(cookieParser());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
});
app.use(limiter);

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  console.log("Headers:", req.headers);
  console.log("Body:", req.body);
  next();
});

// CORS configuration
app.use(
  cors({
    origin: "*", // Allow all origins
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type", "Authorization", "X-CSRF-Token"],
    credentials: true,
    maxAge: 86400,
  })
);

// Session configuration
app.use(
  session({
    secret: process.env.SESSION_SECRET || "your-secret-key",
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: process.env.NODE_ENV === "production",
      httpOnly: true,
      sameSite: "strict",
      maxAge: 24 * 60 * 60 * 1000,
    },
    name: "sessionId",
  })
);

// CSRF protection setup (but not automatically applied)
const csrfProtection = csrf({
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "strict",
  },
});

// Don't apply csrfProtection globally
// app.use(csrfProtection);

// Health check endpoint that doesn't require CSRF
app.get("/health", (req, res) => {
  console.log("Health check request received");
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Get CSRF token (protected with CSRF)
app.get("/csrf-token", csrfProtection, (req, res) => {
  console.log("Received request for CSRF token");
  try {
    const token = req.csrfToken();
    console.log("Generated CSRF token successfully");
    res.json({
      csrfToken: token,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error("Error generating CSRF token:", error);
    res.status(500).json({
      error: "Failed to generate CSRF token",
      details:
        process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
});

// Create Razorpay order
app.post("/create-payment-intent", csrfProtection, async (req, res) => {
  try {
    const { amount, currency, orderId } = req.body;

    // Input validation
    if (!amount || !currency || !orderId) {
      return res.status(400).json({
        error: "Missing required fields",
        required: ["amount", "currency", "orderId"],
      });
    }

    if (isNaN(amount) || amount <= 0) {
      return res.status(400).json({
        error: "Invalid amount",
        message: "Amount must be a positive number",
      });
    }

    // Create Razorpay order
    const options = {
      amount: amount,
      currency: currency,
      receipt: orderId,
      payment_capture: 1,
    };

    console.log("Creating Razorpay order with options:", options);
    const order = await razorpay.orders.create(options);
    console.log("Razorpay order created:", order);

    res.json({
      clientSecret: order.id,
      id: order.id,
      status: order.status,
      created: order.created_at,
      amount: order.amount,
      currency: order.currency,
      receipt: order.receipt,
      key: "rzp_test_47mpRvV2Yh9XLZ", // Add Razorpay key for client
    });
  } catch (error) {
    console.error("Error creating Razorpay order:", error);
    res.status(500).json({
      error: "Payment processing failed",
      details:
        process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
});

// Verify and confirm order
app.post("/confirm-order", csrfProtection, async (req, res) => {
  try {
    const {
      orderId,
      paymentIntentId,
      razorpay_payment_id,
      razorpay_signature,
    } = req.body;

    // Input validation
    if (
      !orderId ||
      !paymentIntentId ||
      !razorpay_payment_id ||
      !razorpay_signature
    ) {
      return res.status(400).json({
        error: "Missing required fields",
        required: [
          "orderId",
          "paymentIntentId",
          "razorpay_payment_id",
          "razorpay_signature",
        ],
      });
    }

    // Verify payment signature according to Razorpay documentation
    const crypto = require("crypto");
    const secret = "0je47WgWBGYVUQgpwYLpfHup";

    // Generate HMAC SHA256 signature - should be orderId|paymentId
    const payload = `${paymentIntentId}|${razorpay_payment_id}`;
    const generated_signature = crypto
      .createHmac("sha256", secret)
      .update(payload)
      .digest("hex");

    console.log("Verifying payment signature...");
    console.log("Payload for signature:", payload);
    console.log("Generated signature:", generated_signature);
    console.log("Received signature:", razorpay_signature);

    if (generated_signature === razorpay_signature) {
      // Payment is verified
      console.log("Payment verified successfully");
      res.json({
        success: true,
        orderId,
        paymentStatus: "succeeded",
        paymentId: razorpay_payment_id,
        timestamp: new Date().toISOString(),
        message: "Order confirmed successfully",
      });
    } else {
      console.log("Payment verification failed");
      res.status(400).json({
        error: "Payment verification failed",
        status: "failed",
        message: "Invalid payment signature",
      });
    }
  } catch (error) {
    console.error("Error confirming order:", error);
    res.status(500).json({
      error: "Order confirmation failed",
      details:
        process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
});

// Global error handling middleware
app.use((err, req, res, next) => {
  console.error("Error:", err);

  if (err.code === "EBADCSRFTOKEN") {
    return res.status(403).json({
      error: "Invalid CSRF token",
      message: "Security verification failed. Please try again.",
    });
  }

  res.status(500).json({
    error: "Internal Server Error",
    message:
      process.env.NODE_ENV === "development"
        ? err.message
        : "An unexpected error occurred",
  });
});

// Create server with proper error handling
const server = app.listen(port, "0.0.0.0", () => {
  console.log(`Server running on port ${port}`);
  console.log(`Environment: ${process.env.NODE_ENV || "development"}`);
  console.log("Using Razorpay Payment Gateway");
});

// Handle server errors
server.on("error", (error) => {
  console.error("Server error:", error);
  if (error.code === "EADDRINUSE") {
    console.error(`Port ${port} is already in use`);
    process.exit(1);
  }
});

// Handle process termination
const gracefulShutdown = (signal) => {
  console.log(`${signal} received. Shutting down gracefully...`);
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
};

process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));

// Handle uncaught exceptions
process.on("uncaughtException", (error) => {
  console.error("Uncaught Exception:", error);
  gracefulShutdown("Uncaught Exception");
});

// Handle unhandled promise rejections
process.on("unhandledRejection", (reason, promise) => {
  console.error("Unhandled Rejection at:", promise, "reason:", reason);
  gracefulShutdown("Unhandled Rejection");
});
