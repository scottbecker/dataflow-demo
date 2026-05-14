import argparse
import json
import logging
import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.io.avroio import WriteToAvro
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
import dataflow_utils

# Define the Avro schema
AVRO_SCHEMA = {
    "type": "record",
    "name": "LogRecord",
    "fields": [
        {"name": "timestamp", "type": "string"},
        {"name": "level", "type": "string"},
        {"name": "message", "type": "string"},
        {"name": "user_id", "type": "int"},
        {"name": "ip_address", "type": "string"}
    ]
}

def run(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--input',
        dest='input',
        required=True,
        help='Input JSON file(s) to process.')
    parser.add_argument(
        '--output',
        dest='output',
        required=True,
        help='Output Avro file prefix.')
    
    known_args, pipeline_args = parser.parse_known_args(argv)

    pipeline_options = PipelineOptions(pipeline_args)
    # save_main_session is important for Dataflow workers to access global variables
    pipeline_options.view_as(SetupOptions).save_main_session = True

    with beam.Pipeline(options=pipeline_options) as p:
        (
            p
            | 'Read JSON' >> ReadFromText(known_args.input)
            | 'Parse JSON' >> beam.Map(json.loads)
            | 'Filter Valid Records' >> beam.Filter(dataflow_utils.validate_record)
            | 'Log Processing' >> beam.Map(dataflow_utils.log_and_return)
            | 'Write to Avro' >> WriteToAvro(
                known_args.output,
                schema=AVRO_SCHEMA,
                file_name_suffix='.avro'
            )
        )

if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()
