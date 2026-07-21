import mysql.connector
from mysql.connector import Error
import settings

def extract_ddl(host, user, password, database, output_file="ddl_export.sql"):
    """
    Connects to a MySQL database and extracts table schemas and indices
    without copying the data.
    """
    try:
        # 1. Establish Connection
        connection = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database,
            port = 9002
        )

        if connection.is_connected():
            print(f"Successfully connected to database: {database}")
            cursor = connection.cursor()

            # 2. Get Table DDL
            print("Fetching table definitions...")
            cursor.execute(f"SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = '{database}' AND TABLE_TYPE = 'BASE TABLE'")
            tables = cursor.fetchall()

            ddl_script = f"-- DDL Export for database: {database}\n-- Generated: {__import__('datetime').datetime.now()}\n\n"
            ddl_script += f"USE `{database}`;\n\n"

            for (table_name,) in tables:
                # Get the exact CREATE TABLE statement
                cursor.execute(f"SHOW CREATE TABLE `{database}`.`{table_name}`")
                create_stmt = cursor.fetchone()[1]
                
                ddl_script += f"-- ----------------------------\n"
                ddl_script += f"-- Table: {table_name}\n"
                ddl_script += f"-- ----------------------------\n"
                ddl_script += f"DROP TABLE IF EXISTS `{table_name}`;\n"
                ddl_script += f"{create_stmt};\n\n"

                # 3. Get Indices for this table
                # SHOW INDEX returns all keys and indices
                cursor.execute(f"SHOW INDEX FROM `{table_name}` FROM `{database}`")
                indices = cursor.fetchall()
                
                if indices:
                    ddl_script += f"-- Indices for {table_name}\n"
                    # We use the information from SHOW INDEX to reconstruct CREATE INDEX statements
                    # Note: MySQL keeps index names inside the CREATE TABLE statement, but 
                    # separating them is useful for migration scripts.
                    
                    # Group indices by name to handle composite keys
                    index_groups = {}
                    for row in indices:
                        # SHOW INDEX columns: (Table, Non_unique, Key_name, Seq_in_index, Column_name, etc)
                        key_name = row[2]
                        if key_name not in index_groups:
                            index_groups[key_name] = []
                        index_groups[key_name].append(row)

                    for key_name, cols in index_groups.items():
                        if key_name == "PRIMARY":
                            # Primary keys are part of CREATE TABLE, skip duplication unless explicitly wanted
                            continue 

                        is_unique = "UNIQUE" if cols[0][1] == 0 else ""
                        col_list = ", ".join([f"`{c[4]}`" for c in cols]) # Column names
                        idx_type = cols[0][10] if len(cols) > 0 and cols[0][10] else "BTREE"
                        
                        ddl_script += f"CREATE {is_unique} INDEX `{key_name}` ON `{table_name}` ({col_list}) USING {idx_type};\n"

                    ddl_script += "\n"

            # 4. Write to File
            with open(output_file, 'w') as f:
                f.write(ddl_script)

            print(f"Successfully extracted DDL to: {output_file}")

    except Error as e:
        print(f"Error while connecting to MySQL: {e}")
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            print("MySQL connection is closed.")

# --- Configuration ---
if __name__ == "__main__":
    # REPLACE THESE VALUES
    CONFIG = {
        "host": "localhost",
        "user": settings.user,
        "password": settings.password,
        "database": "dpo_osprey",
        "output_file": "osprey_database_structure.sql"
    }

    extract_ddl(**CONFIG)
    
