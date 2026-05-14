import logging

logger = logging.getLogger('pipeline')

def log_and_return(record):
    """A simple utility function to demonstrate multi-file packaging."""
    logger.info(f"Processing record for user: {record.get('user_id')}")
    return record

def validate_record(record):
    """Basic validation for log records."""
    required_fields = ['timestamp', 'level', 'message', 'user_id', 'ip_address']
    return all(field in record for field in required_fields)
