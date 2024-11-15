import streamlit as st
import mysql.connector
import pandas as pd
import base64

# CSS for background image
def add_custom_styles(image_path):
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode()
    st.markdown(
        f"""
        <style>
        .stApp {{
            background-image: url("data:image/png;base64,{encoded_string}");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }}
        h1, h2, h3 {{
            color: black !important;
        }}
        select {{
            background-color: black !important;
            color: white !important;
        }}
        </style>
        """,
        unsafe_allow_html=True,
    )

# Database connection
def get_db_connection(username, password):
    try:
        return mysql.connector.connect(
            host="localhost",
            user=username,
            password=password,
            database="wildlife_sanctuary"
        )
    except mysql.connector.Error as e:
        st.error(f"Error connecting to the database: {e}")
        return None

# Fetch table data
def fetch_table(conn, query):
    cursor = conn.cursor(dictionary=True)
    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()
    return pd.DataFrame(result) if result else None

# Insert or update data
def execute_query(conn, query, values):
    try:
        cursor = conn.cursor()
        cursor.execute(query, values)
        conn.commit()
        st.success("Operation successful!")
    except mysql.connector.Error as e:
        st.error(f"Error: {e}")

# Callback for population adjustment
def adjust_population_callback():
    conn = get_db_connection(st.session_state.username, st.session_state.password)
    if conn:
        adjustment = st.session_state.population_adjustment
        query = "UPDATE species SET population = population + %s WHERE species_id = %s;"
        execute_query(conn, query, (adjustment, st.session_state.species_id))
        conn.close()

# Procedure to reset package popularity
def reset_popularity_callback():
    conn = get_db_connection(st.session_state.username, st.session_state.password)
    if conn:
        cursor = conn.cursor()
        cursor.callproc('reset_package_popularity', [st.session_state.reset_package_id])
        conn.commit()
        for result in cursor.stored_results():
            st.write(result.fetchone()[0])  # Display success or error message
        cursor.close()
        conn.close()

# Callback functions for each form action
def update_package_callback():
    conn = get_db_connection(st.session_state.username, st.session_state.password)
    if conn:
        query = "UPDATE package SET price = %s WHERE package_id = %s"
        execute_query(conn, query, (st.session_state.new_price, st.session_state.package_id))

        # Update habitat associations if provided
        if st.session_state.new_habitat_ids.strip():
            query = "DELETE FROM package_habitat WHERE package_id = %s"
            execute_query(conn, query, (st.session_state.package_id,))

            habitat_ids_list = [int(h.strip()) for h in st.session_state.new_habitat_ids.split(",") if h.strip().isdigit()]
            for habitat_id in habitat_ids_list:
                query = "INSERT INTO package_habitat (package_id, habitat_id) VALUES (%s, %s)"
                execute_query(conn, query, (st.session_state.package_id, habitat_id))
        conn.close()

def add_package_callback():
    conn = get_db_connection(st.session_state.username, st.session_state.password)
    if conn:
        query = "INSERT INTO package (package_name, price) VALUES (%s, %s)"
        execute_query(conn, query, (st.session_state.package_name, st.session_state.price))

        cursor = conn.cursor()
        cursor.execute("SELECT LAST_INSERT_ID() AS package_id")
        package_id = cursor.fetchone()["package_id"]

        habitat_ids_list = [int(h.strip()) for h in st.session_state.habitat_ids.split(",") if h.strip().isdigit()]
        for habitat_id in habitat_ids_list:
            query = "INSERT INTO package_habitat (package_id, habitat_id) VALUES (%s, %s)"
            execute_query(conn, query, (package_id, habitat_id))
        conn.close()

def remove_tourist_callback():
    conn = get_db_connection(st.session_state.username, st.session_state.password)
    if conn:
        query = "DELETE FROM tourist WHERE tourist_id = %s"
        execute_query(conn, query, (st.session_state.tourist_id,))
        conn.close()

def edit_facility_callback():
    conn = get_db_connection(st.session_state.username, st.session_state.password)
    if conn:
        query = """
            UPDATE facilities_and_stalls 
            SET name = %s, opening_hours = %s 
            WHERE facility_id = %s
        """
        execute_query(conn, query, (st.session_state.edit_name, st.session_state.edit_opening_hours, st.session_state.facility_id))
        conn.close()

def delete_facility_callback():
    conn = get_db_connection(st.session_state.username, st.session_state.password)
    if conn:
        query = "DELETE FROM facilities_and_stalls WHERE facility_id = %s"
        execute_query(conn, query, (st.session_state.facility_id,))
        conn.close()

def add_facility_callback():
    conn = get_db_connection(st.session_state.username, st.session_state.password)
    if conn:
        query = """
            INSERT INTO facilities_and_stalls (name, description, opening_hours, stall_type, habitat_id)
            VALUES (%s, %s, %s, %s, %s)
        """
        execute_query(conn, query, (
            st.session_state.name, st.session_state.description,
            st.session_state.opening_hours, st.session_state.stall_type,
            st.session_state.habitat_id
        ))
        conn.close()

def show_dashboard(conn, username):
    st.header(f"Welcome, {username.upper()}")
    is_officer = username.startswith("o")

    # Display habitats with species IDs and tourist count
    habitat_species_query = """
        SELECT h.habitat_id, h.name AS habitat_name,
               GROUP_CONCAT(DISTINCT s.species_id ORDER BY s.species_id) AS species_ids,
               COUNT(DISTINCT t.tourist_id) AS tourist_count
        FROM habitat h
        LEFT JOIN species s ON h.habitat_id = s.habitat_id
        LEFT JOIN package_habitat ph ON h.habitat_id = ph.habitat_id
        LEFT JOIN tourist t ON ph.package_id = t.package_id
        GROUP BY h.habitat_id
    """
    habitat_species = fetch_table(conn, habitat_species_query)

    st.subheader("Habitats and Species with Tourist Count")
    if habitat_species is not None:
        st.dataframe(habitat_species)

    # Display species details with adjustable population
    species_query = """
        SELECT species_id, name AS species_name, population
        FROM species
    """
    species = fetch_table(conn, species_query)

    st.subheader("Species Information")
    if species is not None:
        st.dataframe(species)

        if is_officer:
            with st.form(key="adjust_population_form"):
                st.number_input("Species ID for Population Adjustment", min_value=1, step=1, key="species_id")
                st.number_input("Population Adjustment Value (positive or negative)", min_value=-100, max_value=100, value=0, step=1, key="population_adjustment")
                st.form_submit_button("Adjust Population", on_click=adjust_population_callback)

    # Display and manage packages
    packages_query = """
        SELECT p.package_id, p.package_name, p.price, p.popularity,
               COUNT(DISTINCT t.tourist_id) AS tourist_count, GROUP_CONCAT(DISTINCT ph.habitat_id ORDER BY ph.habitat_id) AS habitat_ids
        FROM package p
        LEFT JOIN package_habitat ph ON p.package_id = ph.package_id
        LEFT JOIN tourist t ON p.package_id = t.package_id
        GROUP BY p.package_id
        ORDER BY tourist_count DESC
    """
    packages = fetch_table(conn, packages_query)

    st.subheader("Packages (Ranked by Tourist Count)")
    if packages is not None:
        st.dataframe(packages)
        if is_officer:
            with st.form(key="update_package_form"):
                st.number_input("Package ID to Edit", min_value=1, step=1, key="package_id")
                st.number_input("New Price", min_value=0.0, step=0.01, key="new_price")
                st.text_input("New Habitat IDs (comma-separated)", key="new_habitat_ids")
                st.form_submit_button("Update Package", on_click=update_package_callback)

            with st.form(key="add_package_form"):
                st.text_input("Package Name", key="package_name")
                st.number_input("Price", min_value=0.0, step=0.01, key="price")
                st.text_input("Habitat IDs (comma-separated)", key="habitat_ids")
                st.form_submit_button("Add New Package", on_click=add_package_callback)

            with st.form(key="reset_popularity_form"):
                st.number_input("Package ID to Reset Popularity", min_value=1, step=1, key="reset_package_id")
                st.form_submit_button("Reset Package Popularity", on_click=reset_popularity_callback)

    # Display and manage tourists
    tourists = fetch_table(conn, "SELECT * FROM tourist")

    st.subheader("Tourists")
    if tourists is not None:
        st.dataframe(tourists)
        if is_officer:
            with st.form(key="remove_tourist_form"):
                st.number_input("Tourist ID to Remove", min_value=1, step=1, key="tourist_id")
                st.form_submit_button("Remove Tourist", on_click=remove_tourist_callback)

    # Display and manage facilities
    facilities = fetch_table(conn, "SELECT * FROM facilities_and_stalls")

    st.subheader("Facilities and Stalls")
    if facilities is not None:
        st.dataframe(facilities)
        with st.form(key="edit_facility_form"):
            st.number_input("Facility ID to Edit/Delete", min_value=1, step=1, key="facility_id")
            st.text_input("New Facility Name", key="edit_name")
            st.text_input("New Opening Hours", key="edit_opening_hours")
            st.form_submit_button("Edit Facility", on_click=edit_facility_callback)
            st.form_submit_button("Delete Facility", on_click=delete_facility_callback)

        with st.form(key="add_facility_form"):
            st.text_input("Facility Name", key="name")
            st.text_area("Description", key="description")
            st.text_input("Opening Hours", key="opening_hours")
            st.selectbox("Stall Type", ["food", "souvenir", "information"], key="stall_type")
            st.number_input("Habitat ID", min_value=1, step=1, key="habitat_id")
            st.form_submit_button("Add Facility", on_click=add_facility_callback)

    # Display wildlife officers and tour guides
    if is_officer:
        wildlife_officers = fetch_table(conn, "SELECT * FROM wildlife_officers")
        st.subheader("Wildlife Officers")
        if wildlife_officers is not None:
            st.dataframe(wildlife_officers)

    tour_guides = fetch_table(conn, "SELECT * FROM tour_guide")
    st.subheader("Tour Guides")
    if tour_guides is not None:
        st.dataframe(tour_guides)

    # Display habitat with the most tourist visits
    habitat_popularity = fetch_table(conn, """
        SELECT h.habitat_id, h.name AS habitat_name, habitat_counts.tourist_count
        FROM habitat h
        JOIN (
            SELECT ph.habitat_id, COUNT(DISTINCT t.tourist_id) AS tourist_count
            FROM package_habitat ph
            JOIN tourist t ON ph.package_id = t.package_id
            GROUP BY ph.habitat_id
        ) AS habitat_counts ON h.habitat_id = habitat_counts.habitat_id
        ORDER BY habitat_counts.tourist_count DESC
        LIMIT 1;
    """)
    st.subheader("Habitat with Most Tourist Visits")
    if habitat_popularity is not None:
        st.dataframe(habitat_popularity)


# Main application
def main():
    add_custom_styles("background.jpg")  # Replace with the actual image path
    st.title("Wildlife Sanctuary Dashboard")
    st.text_input("Username", key="username")
    st.text_input("Password", type="password", key="password")
    
    if st.button("Login"):
        conn = get_db_connection(st.session_state.username, st.session_state.password)
        if conn:
            show_dashboard(conn, st.session_state.username)
            conn.close()

if __name__ == "__main__":
    main()
