# ============================================================
# FinSight AI Layer — app.py
# Phase 7: Natural Language Business Intelligence
# PostgreSQL + Google Gemini 2.0 Flash + Streamlit
# ============================================================

import os
import re
import time
import pandas as pd
import streamlit as st
from dotenv import load_dotenv
from google import genai
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

load_dotenv()


# ── secret loader ────────────────────────────────────────────
# Works for both local .env and Streamlit Cloud secrets

def getsecret(key: str, default: str | None = None) -> str | None:
    try:
        return st.secrets[key]
    except (KeyError, FileNotFoundError, AttributeError):
        return os.environ.get(key, default)


# ── page configuration ───────────────────────────────────────

st.set_page_config(
    page_title="FinSight AI",
    page_icon="💹",
    layout="wide",
    initial_sidebar_state="expanded",
)


# ── global CSS ───────────────────────────────────────────────

st.markdown("""
<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

html, body, [class*="css"] { font-family: 'Inter', sans-serif; }

[data-testid="stAppViewContainer"] {
    background:
        radial-gradient(circle at top left, rgba(14,165,233,0.14), transparent 28%),
        radial-gradient(circle at top right, rgba(16,185,129,0.12), transparent 30%),
        linear-gradient(180deg, #07111f 0%, #0b1220 45%, #0f172a 100%);
    color: #f8fafc;
}
[data-testid="stHeader"] { background: rgba(0,0,0,0); }
[data-testid="stSidebar"] {
    background: linear-gradient(180deg, #0b1220 0%, #111827 100%);
    border-right: 1px solid rgba(255,255,255,0.06);
}
.block-container {
    max-width: 1240px;
    padding-top: 1.8rem;
    padding-bottom: 2rem;
}
h1, h2, h3, h4, h5, h6, p, label, div, span { color: #f8fafc; }

.hero-wrap {
    padding: 2rem;
    border-radius: 24px;
    background: linear-gradient(135deg, rgba(14,165,233,0.18), rgba(16,185,129,0.12));
    border: 1px solid rgba(255,255,255,0.10);
    box-shadow: 0 16px 40px rgba(0,0,0,0.30);
    margin-bottom: 1.25rem;
}
.hero-badge {
    display: inline-block;
    padding: 0.45rem 0.8rem;
    border-radius: 999px;
    background: rgba(255,255,255,0.08);
    border: 1px solid rgba(255,255,255,0.10);
    color: #bfdbfe;
    font-size: 0.82rem;
    font-weight: 600;
    margin-bottom: 0.9rem;
}
.hero-title {
    font-size: 2.3rem;
    font-weight: 800;
    line-height: 1.1;
    margin-bottom: 0.75rem;
    letter-spacing: -0.02em;
}
.hero-subtitle {
    color: #cbd5e1;
    font-size: 1.02rem;
    line-height: 1.7;
}

.metric-card, .panel, .question-panel {
    background: rgba(255,255,255,0.045);
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 18px;
    padding: 1rem;
    box-shadow: 0 10px 26px rgba(0,0,0,0.18);
}
.metric-card { min-height: 132px; }
.metric-label {
    font-size: 0.84rem;
    color: #93c5fd;
    margin-bottom: 0.45rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.04em;
}
.metric-text {
    color: #e5e7eb;
    font-size: 0.97rem;
    line-height: 1.6;
}
.section-title {
    font-size: 1.15rem;
    font-weight: 700;
    margin-bottom: 0.6rem;
}

.status-success {
    padding: 0.85rem 1rem;
    border-radius: 14px;
    background: rgba(16,185,129,0.12);
    border: 1px solid rgba(16,185,129,0.25);
    color: #d1fae5;
    margin: 0.9rem 0 1rem;
    font-weight: 500;
}
.status-warning {
    padding: 0.85rem 1rem;
    border-radius: 14px;
    background: rgba(245,158,11,0.12);
    border: 1px solid rgba(245,158,11,0.25);
    color: #fde68a;
    margin-top: 0.9rem;
    font-weight: 500;
}
.status-error {
    padding: 0.85rem 1rem;
    border-radius: 14px;
    background: rgba(239,68,68,0.12);
    border: 1px solid rgba(239,68,68,0.25);
    color: #fecaca;
    margin-top: 0.9rem;
    font-weight: 500;
}
.small-note {
    color: #94a3b8;
    font-size: 0.88rem;
    line-height: 1.6;
    margin-top: 0.8rem;
}

.hist-item {
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.07);
    border-radius: 10px;
    padding: 0.55rem 0.7rem;
    margin-bottom: 0.45rem;
    font-size: 0.88rem;
    color: #cbd5e1;
}
.hist-rows {
    color: #64748b;
    font-size: 0.78rem;
    margin-top: 0.2rem;
}

div[data-testid="stTextArea"] textarea {
    background-color: rgba(15,23,42,0.85) !important;
    color: #f8fafc !important;
    caret-color: #f8fafc !important;
    border-radius: 14px !important;
    border: 1px solid rgba(255,255,255,0.12) !important;
    font-size: 0.97rem !important;
}
div[data-testid="stTextArea"] textarea::placeholder {
    color: #64748b !important;
    opacity: 1 !important;
}
div[data-testid="stTextArea"] label { color: #cbd5e1 !important; }

div.stButton > button {
    width: 100%;
    border-radius: 14px;
    padding: 0.85rem 1rem;
    font-weight: 700;
    background: linear-gradient(135deg, #0ea5e9 0%, #14b8a6 100%);
    color: white;
    border: none;
    box-shadow: 0 10px 24px rgba(14,165,233,0.22);
    transition: filter 0.15s;
}
div.stButton > button:hover { filter: brightness(1.06); }

[data-testid="stSidebar"] div.stButton > button {
    background: rgba(14,165,233,0.10) !important;
    border: 1px solid rgba(14,165,233,0.22) !important;
    color: #dbeafe !important;
    box-shadow: none !important;
    font-weight: 500 !important;
    padding: 0.65rem 0.9rem !important;
    font-size: 0.90rem !important;
    text-align: left !important;
}
</style>
""", unsafe_allow_html=True)


# ── credentials ──────────────────────────────────────────────

GEMINI_API_KEY = getsecret("GEMINI_API_KEY")
DATABASE_URL = getsecret("DATABASE_URL_LOCAL")

if not GEMINI_API_KEY:
    st.error("Missing GEMINI_API_KEY. Add it to your .env file.")
    st.stop()

if not DATABASE_URL:
    st.error("Missing DATABASE_URL_LOCAL. Add it to your .env file.")
    st.stop()


# ── client initialisation ────────────────────────────────────

try:
    gemini_client = genai.Client(api_key=GEMINI_API_KEY)
except Exception as client_error:
    st.error(f"Gemini client initialisation failed: {client_error}")
    st.stop()

try:
    db_engine = create_engine(
        DATABASE_URL,
        pool_pre_ping=True,
        pool_recycle=300,
    )
    with db_engine.connect() as _test_conn:
        _test_conn.execute(text("SELECT 1"))
except Exception as db_error:
    st.error(f"PostgreSQL connection failed: {db_error}")
    st.stop()

GEMINI_MODEL = "gemini-2.0-flash"


# ── schema context ───────────────────────────────────────────
# Uses ONLY the user-confirmed current FinSight names

SCHEMA_CONTEXT = """
You are a PostgreSQL SQL expert for FinSight, a fintech transaction analytics project.

CRITICAL RULES:
1. All objects are in the fintech schema.
2. Always prefix tables and views with fintech.
3. Use only the exact tables, views, and columns listed below.
4. Return only one valid PostgreSQL SELECT query.
5. No markdown, no backticks, no explanation, SQL only.
6. Never generate INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE, CREATE, GRANT, REVOKE, or EXEC.
7. Use NULLIF() in denominators where division happens.
8. Use ROUND(..., 2) for percentages and financial ratios when appropriate.
9. Prefer the base tables unless a listed view directly fits the question.
10. If the business question mentions fraud, declines, payment methods, customer segments, merchants, geography, or time trends, use the exact matching fields below.

CORE TABLES:

fintech.dim_time
- date_key
- full_date
- day_of_week
- week_number
- month_number
- quarter
- year
- is_weekend
- is_public_holiday
- year_month
- month

fintech.dim_customer
- customer_id
- customer_name
- customer_segment
- acquisition_channel
- kyc_status
- signup_date
- city
- state
- geography_tier

fintech.dim_merchant
- merchant_id
- merchant_name
- merchant_category
- merchant_tier
- city
- state
- geography_tier

fintech.dim_payment_method
- payment_method_id
- payment_method_name
- payment_channel_type
- fee_percentage

fintech.dim_geography
- geography_id
- state_name
- geography_tier

fintech.fact_transactions
- transaction_id
- date_key
- customer_id
- merchant_id
- payment_method_id
- geography_id
- transaction_amount
- fee_amount
- net_amount
- status
- is_fraud
- processing_time_seconds
- transaction_hour
- decline_category
- decline_reason

CONFIRMED JOINS:
- fintech.fact_transactions.date_key = fintech.dim_time.date_key
- fintech.fact_transactions.customer_id = fintech.dim_customer.customer_id
- fintech.fact_transactions.merchant_id = fintech.dim_merchant.merchant_id
- fintech.fact_transactions.payment_method_id = fintech.dim_payment_method.payment_method_id
- fintech.fact_transactions.geography_id = fintech.dim_geography.geography_id

CONFIRMED STATUS FIELD:
- fintech.fact_transactions.status

COMMON STATUS VALUES:
- success
- failed
- pending
- refunded

IMPORTANT BUSINESS FIELDS:
- Fraud flag: fintech.fact_transactions.is_fraud
- Decline category: fintech.fact_transactions.decline_category
- Decline reason: fintech.fact_transactions.decline_reason
- Payment method name: fintech.dim_payment_method.payment_method_name
- Geography state: fintech.dim_geography.state_name
- Customer segment: fintech.dim_customer.customer_segment
- Merchant category: fintech.dim_merchant.merchant_category
- Merchant tier: fintech.dim_merchant.merchant_tier

OPTIONAL VIEWS:
- fintech.vwtransactionoverview
- fintech.vwmonthlykpi
- fintech.vwpaymentmethodperformance
- fintech.vwupideclineanalysis
- fintech.vwcustomersegmentperformance
- fintech.vwfraudgeographicsummary

USEFUL PATTERNS:
- Monthly trend: join fintech.fact_transactions to fintech.dim_time on date_key
- Successful revenue: filter WHERE ft.status = 'success'
- Failed transactions: filter WHERE ft.status = 'failed'
- Fraud rate:
  ROUND(
    SUM(CASE WHEN ft.is_fraud = TRUE THEN 1 ELSE 0 END)::numeric
    / NULLIF(COUNT(*), 0) * 100,
    2
  )
- Revenue share:
  ROUND(
    SUM(ft.net_amount)
    / NULLIF(SUM(SUM(ft.net_amount)) OVER (), 0) * 100,
    2
  )
- UPI decline analysis:
  join fintech.dim_payment_method dpm
    on ft.payment_method_id = dpm.payment_method_id
  then filter dpm.payment_method_name = 'UPI'

ALWAYS:
- Use aliases like ft, dt, dc, dm, dpm, dg when useful.
- For time analysis, join dim_time.
- For payment method analysis, join dim_payment_method.
- For customer segment analysis, join dim_customer.
- For merchant analysis, join dim_merchant.
- For geography analysis, join dim_geography.
"""


# ── constants ────────────────────────────────────────────────

EXAMPLE_QUESTIONS: list[str] = [
    "Which payment method had the highest fraud rate?",
    "What percentage of UPI failed transaction value looks technically recoverable?",
    "Which customer segment contributed the most revenue this year?",
    "Which states have the highest concentration of fraud?",
    "How are failed transactions affecting net revenue by payment method?",
]

BLOCKED_SQL_KEYWORDS: list[str] = [
    "DELETE", "UPDATE", "DROP", "INSERT",
    "TRUNCATE", "ALTER", "CREATE", "GRANT", "REVOKE", "EXEC",
]


# ── gemini wrapper ───────────────────────────────────────────

def call_gemini(prompt: str, max_retries: int = 2, base_wait: int = 2) -> str:
    """
    Calls Gemini with retry for temporary service issues.
    Stops immediately for quota or rate-limit errors.
    """
    wait = base_wait
    last_error: Exception | None = None

    for attempt in range(max_retries + 1):
        try:
            response = gemini_client.models.generate_content(
                model=GEMINI_MODEL,
                contents=prompt,
            )
            return (response.text or "").strip()

        except Exception as api_error:
            err_str = str(api_error)

            if "429" in err_str or "RESOURCE_EXHAUSTED" in err_str:
                raise RuntimeError(
                    "Gemini API quota is currently exhausted. "
                    "Please retry later. The SQL and Power BI layers of FinSight still remain usable."
                ) from api_error

            if ("503" in err_str or "UNAVAILABLE" in err_str) and attempt < max_retries:
                last_error = api_error
                time.sleep(wait)
                wait *= 2
                continue

            raise RuntimeError(f"Gemini API error: {api_error}") from api_error

    raise RuntimeError(str(last_error) if last_error else "Max retries exceeded.")


def clean_sql_text(raw_output: str) -> str:
    cleaned = raw_output.strip()
    cleaned = re.sub(r"```sql", "", cleaned, flags=re.IGNORECASE)
    cleaned = cleaned.replace("```", "").strip()
    cleaned = (
        cleaned
        .replace("≥", ">=")
        .replace("≤", "<=")
        .replace("≠", "!=")
        .replace("\u2013", "-")
        .replace("\u2014", "--")
    )
    return cleaned


def is_sql_safe(sql_text: str) -> tuple[bool, str]:
    if not sql_text:
        return False, "Empty query."

    stripped = sql_text.strip()
    upper = stripped.upper()

    if not upper.startswith("SELECT"):
        return False, "Query must begin with SELECT."

    for keyword in BLOCKED_SQL_KEYWORDS:
        if re.search(rf"\b{keyword}\b", upper):
            return False, f"Blocked keyword detected: {keyword}"

    if "FINTECH." not in upper:
        return False, "Query must reference the fintech schema."

    return True, "OK"


def generate_sql_query(user_question: str) -> str:
    prompt = (
        f"{SCHEMA_CONTEXT}\n\n"
        f"Business question: {user_question}\n\n"
        "Return only one valid PostgreSQL SELECT query. "
        "No markdown. No explanation. SQL only."
    )
    raw_output = call_gemini(prompt)
    return clean_sql_text(raw_output)


def fix_sql_query(user_question: str, failed_sql: str, error_msg: str) -> str:
    prompt = (
        f"{SCHEMA_CONTEXT}\n\n"
        f"Business question: {user_question}\n\n"
        f"The following SQL query failed:\n{failed_sql}\n\n"
        f"Database error message: {error_msg}\n\n"
        "Fix the SQL using only the listed schema names. "
        "Return only the corrected PostgreSQL SELECT query. "
        "No markdown. No explanation. SQL only."
    )
    raw_output = call_gemini(prompt)
    return clean_sql_text(raw_output)


def run_sql_query(sql_text: str) -> pd.DataFrame:
    with db_engine.connect() as conn:
        return pd.read_sql_query(text(sql_text), conn)


def generate_local_narrative(user_question: str, result_df: pd.DataFrame) -> str:
    """
    Local fallback summary to reduce Gemini dependency.
    This avoids spending one more API call after SQL execution.
    """
    if result_df.empty:
        return (
            "The query ran successfully but returned no rows. "
            "Try broadening the question or changing the time scope."
        )

    row_count = len(result_df)
    col_count = len(result_df.columns)
    columns_text = ", ".join(result_df.columns.tolist())

    preview_lines = []
    preview_df = result_df.head(3)

    for _, row in preview_df.iterrows():
        parts = [f"{col}={row[col]}" for col in preview_df.columns]
        preview_lines.append(" | ".join(parts))

    preview_text = "\n".join(preview_lines)

    return (
        f"Question asked: {user_question}\n\n"
        f"The SQL query executed successfully and returned {row_count} row(s) "
        f"across {col_count} column(s).\n\n"
        f"Columns returned: {columns_text}\n\n"
        f"Sample output:\n{preview_text}\n\n"
        f"Caution: This is a direct data summary from PostgreSQL output, not a separate AI interpretation."
    )


# ── session state ────────────────────────────────────────────

if "question_history" not in st.session_state:
    st.session_state.question_history = []

if "prefill_question" not in st.session_state:
    st.session_state.prefill_question = ""


# ── sidebar ──────────────────────────────────────────────────

with st.sidebar:
    st.markdown("## 💹 FinSight")
    st.caption("Fintech Transaction Analytics Warehouse\nwith Natural Language BI")
    st.markdown("---")

    st.markdown("#### App Status")
    status_checks = [
        ("Environment loaded", True),
        ("Gemini client ready", True),
        ("PostgreSQL connected", True),
        ("fintech schema enforced", True),
        ("SQL safety validation", True),
        ("Retry logic active", True),
        ("Question history tracked", True),
    ]
    for status_label, status_ok in status_checks:
        icon = "✅" if status_ok else "❌"
        st.write(f"{icon} {status_label}")

    st.markdown("---")
    st.markdown("#### Focus Areas")
    focus_areas = [
        "Revenue trends",
        "Fraud analysis",
        "Payment methods",
        "Customer segments",
        "Geography",
        "UPI decline intelligence",
    ]
    for area in focus_areas:
        st.write(f"• {area}")

    st.markdown("---")
    st.markdown("#### Recent Questions")

    if st.session_state.question_history:
        recent_items = list(reversed(st.session_state.question_history[-5:]))
        for hist_item in recent_items:
            truncated = (
                hist_item["question"][:52] + "…"
                if len(hist_item["question"]) > 52
                else hist_item["question"]
            )
            st.markdown(
                f'<div class="hist-item">{truncated}'
                f'<div class="hist-rows">↳ {hist_item["row_count"]} row(s)</div>'
                f"</div>",
                unsafe_allow_html=True,
            )
    else:
        st.caption("No questions asked yet.")

    st.markdown("---")
    st.caption(f"Model: {GEMINI_MODEL}")
    st.caption("DB: PostgreSQL / fintech schema")
    st.caption("Records: 50,000 transactions")


# ── hero section ─────────────────────────────────────────────

st.markdown(f"""
<div class="hero-wrap">
    <div class="hero-badge">
        Fintech Analytics &bull; Natural Language BI &bull; {GEMINI_MODEL}
    </div>
    <div class="hero-title">FinSight AI Layer</div>
    <div class="hero-subtitle">
        Ask a business question in plain English. The app generates SQL,
        validates it, runs it on PostgreSQL, and returns a safe business-facing answer.
    </div>
</div>
""", unsafe_allow_html=True)

st.markdown(
    f'<div class="status-success">'
    f"✅ Environment loaded. Gemini client initialised. "
    f"PostgreSQL connection verified. fintech schema rules enforced. "
    f"Model: {GEMINI_MODEL}"
    f"</div>",
    unsafe_allow_html=True,
)


# ── metric cards ─────────────────────────────────────────────

mc1, mc2, mc3 = st.columns(3)

with mc1:
    st.markdown("""
    <div class="metric-card">
        <div class="metric-label">Business Goal</div>
        <div class="metric-text">
            Help non-technical users ask fintech business questions and
            receive answers backed by validated SQL execution on PostgreSQL.
        </div>
    </div>
    """, unsafe_allow_html=True)

with mc2:
    st.markdown("""
    <div class="metric-card">
        <div class="metric-label">Coverage</div>
        <div class="metric-text">
            Revenue trends, fraud intelligence, payment method performance,
            customer segments, geography, and UPI decline analysis.
        </div>
    </div>
    """, unsafe_allow_html=True)

with mc3:
    st.markdown("""
    <div class="metric-card">
        <div class="metric-label">Workflow</div>
        <div class="metric-text">
            Question → SQL generation → safety validation →
            PostgreSQL execution → retry on error → output summary.
        </div>
    </div>
    """, unsafe_allow_html=True)

st.write("")


# ── main two-column layout ──────────────────────────────────

left_col, right_col = st.columns([1.7, 1])


# ── left column ─────────────────────────────────────────────

with left_col:
    st.markdown('<div class="question-panel">', unsafe_allow_html=True)
    st.markdown(
        '<div class="section-title">Ask a business question</div>',
        unsafe_allow_html=True,
    )

    user_question = st.text_area(
        label="Enter your question",
        value=st.session_state.prefill_question,
        placeholder="Example: Which payment method had the highest fraud rate last month?",
        height=150,
    )

    if st.session_state.prefill_question:
        st.session_state.prefill_question = ""

    submitted = st.button("🔍 Generate AI Response")

    if submitted:
        question_text = user_question.strip()

        if not question_text:
            st.markdown(
                '<div class="status-warning">⚠️ Please enter a business question before submitting.</div>',
                unsafe_allow_html=True,
            )
        else:
            executed_sql = None
            result_df = None

            try:
                with st.spinner("Generating SQL query..."):
                    generated_sql = generate_sql_query(question_text)

                is_safe, safety_reason = is_sql_safe(generated_sql)

                if not is_safe:
                    st.markdown(
                        f'<div class="status-error">⛔ Query blocked by safety check: {safety_reason}. Please rephrase your question as a data request.</div>',
                        unsafe_allow_html=True,
                    )
                else:
                    try:
                        with st.spinner("Running SQL on PostgreSQL..."):
                            result_df = run_sql_query(generated_sql)
                        executed_sql = generated_sql

                    except (SQLAlchemyError, Exception) as first_error:
                        first_error_msg = str(first_error)

                        obvious_schema_issue = any(
                            phrase in first_error_msg.lower()
                            for phrase in [
                                "does not exist",
                                "undefined column",
                                "undefined table",
                                "column",
                                "relation",
                            ]
                        )

                        if obvious_schema_issue:
                            st.markdown(
                                f'<div class="status-error">⛔ Query failed due to schema mismatch or missing object: {first_error}</div>',
                                unsafe_allow_html=True,
                            )
                        else:
                            with st.spinner("First attempt failed. Retrying with error context..."):
                                corrected_sql = fix_sql_query(
                                    question_text,
                                    generated_sql,
                                    first_error_msg,
                                )

                            is_safe_retry, retry_reason = is_sql_safe(corrected_sql)

                            if not is_safe_retry:
                                st.markdown(
                                    f'<div class="status-error">⛔ Corrected query failed safety check: {retry_reason}</div>',
                                    unsafe_allow_html=True,
                                )
                            else:
                                try:
                                    with st.spinner("Running corrected SQL..."):
                                        result_df = run_sql_query(corrected_sql)
                                    executed_sql = corrected_sql
                                except Exception as second_error:
                                    st.markdown(
                                        f'<div class="status-error">⛔ Query failed after two attempts. Error: {second_error}</div>',
                                        unsafe_allow_html=True,
                                    )

                    if executed_sql:
                        with st.expander("🔎 View Generated SQL", expanded=False):
                            st.code(executed_sql, language="sql")
                            st.caption("Generated by Gemini and validated before execution.")

                    if result_df is not None:
                        st.markdown("### 📊 Query Results")
                        st.dataframe(
                            result_df,
                            use_container_width=True,
                            hide_index=True,
                        )
                        st.caption(f"↳ {len(result_df)} row(s) returned from PostgreSQL")

                        st.markdown("### 💡 Business Insight")
                        st.info(generate_local_narrative(question_text, result_df))

                        st.session_state.question_history.append({
                            "question": question_text,
                            "sql": executed_sql or "",
                            "row_count": len(result_df),
                        })

            except RuntimeError as runtime_err:
                err_msg = str(runtime_err)
                if "quota" in err_msg.lower() or "rate limit" in err_msg.lower():
                    st.markdown(
                        f'<div class="status-warning">⏳ {err_msg}</div>',
                        unsafe_allow_html=True,
                    )
                else:
                    st.markdown(
                        f'<div class="status-error">⛔ {err_msg}</div>',
                        unsafe_allow_html=True,
                    )

    st.markdown(
        '<div class="small-note">'
        "Only safe SELECT queries are allowed. All queries are validated before execution. "
        "If a question keeps failing, check whether the referenced schema object exists in PostgreSQL "
        "and whether the business question matches the actual loaded FinSight tables."
        "</div>",
        unsafe_allow_html=True,
    )
    st.markdown("</div>", unsafe_allow_html=True)


# ── right column ─────────────────────────────────────────────

with right_col:
    st.markdown('<div class="panel">', unsafe_allow_html=True)
    st.markdown(
        '<div class="section-title">Example questions</div>',
        unsafe_allow_html=True,
    )
    st.caption("Click any question to load it into the input box.")

    for idx, example_q in enumerate(EXAMPLE_QUESTIONS):
        if st.button(example_q, key=f"eq_{idx}", use_container_width=True):
            st.session_state.prefill_question = example_q
            st.rerun()

    st.markdown(
        '<div class="status-warning">'
        "⚠️ If a question keeps failing, the most likely causes are a missing PostgreSQL view, "
        "a schema mismatch, or Gemini free-tier quota exhaustion."
        "</div>",
        unsafe_allow_html=True,
    )
    st.markdown("</div>", unsafe_allow_html=True)


# ── footer ───────────────────────────────────────────────────

st.markdown("---")
st.caption(
    "FinSight AI Layer | PostgreSQL + Google Gemini | "
    "Portfolio project by VA | Data is synthetic and generated for demonstration purposes only."
)