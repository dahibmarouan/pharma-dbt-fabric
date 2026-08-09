import os
from pathlib import Path
import duckdb

# Move into pharma_project, so that dbt's internal relative paths
# (../data/raw/*.json) resolve the same way as during a dbt build.
os.chdir(Path(__file__).resolve().parent.parent / "pharma_project")

Path("../exports").mkdir(exist_ok=True)

con = duckdb.connect("data/warehouse.duckdb", read_only=True)
con.execute("COPY main.fct_drug_adverse_events TO '../exports/fct_drug_adverse_events.csv' (HEADER, DELIMITER ',')")
con.execute("COPY main.fct_reaction_adverse_events TO '../exports/fct_reaction_adverse_events.csv' (HEADER, DELIMITER ',')")
con.close()
print("Export complete.")