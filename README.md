# Dataflow/Flink Beam Demo: JSON to Avro

This project demonstrates a runner-agnostic Apache Beam pipeline that converts JSON logs to Avro format. It is configured to run locally, on Google Cloud Dataflow, or on a Dataproc Flink cluster.

## Architecture

- **Pipeline**: `json_to_avro.py` (supported by `dataflow_utils.py`)
- **Primary Data**: `gs://dataflow-demo-central-maps` (centralized in `us-central1`)
- **Infrastructure**:
    - **Local**: `DirectRunner`
    - **Cloud**: `DataflowRunner` (Dataflow Prime)
    - **Cluster**: `FlinkRunner` on Dataproc (`flink-mini-cluster`)

## Local Execution

Run the pipeline locally with organized logging and output:
```bash
./bin/run_local.sh
```
Results will be stored in the `output/` directory.

## Dataproc (Flink) Execution

We use a dedicated Beam Job Server for fast iterative development.

1. **Start the Cluster** (if stopped): `./bin/dataproc_start.sh`
2. **Start the Job Server**: `./bin/dataproc_job_server_start.sh`
3. **Check Status**: `./bin/dataproc_job_server_status.sh`
4. **Submit Jobs**: `./bin/dataproc_job_submit.sh`
5. **Monitor**: `./bin/dataproc_dashboard.sh` (opens Chrome with SOCKS5 proxy)
6. **Stop Server**: `./bin/dataproc_job_server_stop.sh`

## Dataflow Execution

To run on Google Cloud Dataflow Prime:
```bash
./bin/run_gcp.sh
```

## Project Structure

- `bin/`: Automation and lifecycle scripts.
- `json_to_avro.py`: The main Beam pipeline.
- `dataflow_utils.py`: Shared utility functions.
- `output/`: Local run results (git-ignored).
- `processed/`: (Deprecated) Legacy output directory.
