import streamlit as st
import mysql.connector
from datetime import date, timedelta
import base64

# CSS for background image, dropdowns, and heading styling
def add_custom_styles(image_path):
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode()

    st.markdown(
        f"""
        <style>
        /* Background Image */
        .stApp {{
            background-image: url("data:image/png;base64,{encoded_string}");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }}
        
        /* Style for dropdown menus (select elements) */
        select {{
            background-color: black !important;  /* Black background */
            color: white !important;  /* White text */
        }}
        
        /* Style for headings */
        h1, h2, h3 {{
            color: black !important;  /* Black text for all headings */
        }}
        
        /* Extra alignment for better display */
        .stMarkdown {{
            margin-top: 1rem;
        }}
        </style>
        """,
        unsafe_allow_html=True
    )

# Connect to the database
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="tourist",
        password="tour",
        database="wildlife_sanctuary"
    )

# Fetch packages, habitats, and species data
def fetch_packages_and_habitats():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Fetch package details, including popularity
    cursor.execute("SELECT package_id, package_name, price, popularity FROM package")
    packages = cursor.fetchall()

    # Fetch package habitat associations
    cursor.execute("""
        SELECT ph.package_id, h.name AS habitat_name
        FROM package_habitat ph
        JOIN habitat h ON ph.habitat_id = h.habitat_id
    """)
    habitats = cursor.fetchall()

    # Fetch species data
    cursor.execute("""
        SELECT h.name AS habitat_name, s.name AS species_name
        FROM habitat h
        JOIN species s ON h.habitat_id = s.habitat_id
    """)
    species_data = cursor.fetchall()

    conn.close()
    return packages, habitats, species_data

# Group habitats by package
def group_habitats_by_package(habitats):
    grouped = {}
    for habitat in habitats:
        grouped.setdefault(habitat['package_id'], []).append(habitat['habitat_name'])
    return grouped

# Insert tourist registration
def register_tourist(data):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO tourist (name, phone_no, visit_date, package_id, minimum_age, maximum_age, total_people_in_group, total_cost)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            data['name'], data['phone'], data['visit_date'], data['package_id'],
            data['min_age'], data['max_age'], data['group_size'], data['total_cost']
        ))
        conn.commit()
        st.success("Tour registered successfully!")
    except mysql.connector.Error as e:
        st.error(f"Error: {e}")
    finally:
        conn.close()

# Main application
def main():
    # Add background image
    add_custom_styles(r"C:/Users/Barath/Downloads/Student_copy/background.jpg")  # Replace with the actual path to your image

    st.title("Wildlife Sanctuary Tour Registration")
    st.header("Register for a Tour")

    # Fetch data
    packages, habitats, species_data = fetch_packages_and_habitats()
    habitat_groups = group_habitats_by_package(habitats)

    # Initialize total_price as None for dynamic calculations
    total_price = None

    # Registration Form
    with st.form("register_tour"):
        name = st.text_input("Name")
        phone = st.text_input("Contact Number")
        visit_date = st.date_input("Visit Date", min_value=date.today(), max_value=date.today() + timedelta(weeks=2))

        package_options = {
            f"{pkg['package_name']} (${pkg['price']})": pkg for pkg in packages
        }
        selected_package = st.selectbox("Select a Package", list(package_options.keys()))

        group_size = st.number_input("Number of People in Group", min_value=1, max_value=10, step=1)
        min_age = st.number_input("Minimum Age in Group", min_value=5, step=1)
        max_age = st.number_input("Maximum Age in Group", min_value=5, step=1)

        # "Calculate Price" Button (using submit button for calculation)
        calculate_price = st.form_submit_button("Calculate Price")
        if calculate_price:
            selected_package_details = package_options[selected_package]
            total_price = selected_package_details["price"] * group_size
            st.write(f"*Total Price: ${total_price:.2f}*")

        # "Register" Button
        register = st.form_submit_button("Register")
        if register:
            if min_age > max_age:
                st.error("Minimum age cannot be greater than maximum age.")
            else:
                selected_package_details = package_options[selected_package]
                if total_price is None:
                    total_price = selected_package_details["price"] * group_size
                data = {
                    "name": name,
                    "phone": phone,
                    "visit_date": visit_date,
                    "package_id": selected_package_details["package_id"],
                    "min_age": min_age,
                    "max_age": max_age,
                    "group_size": group_size,
                    "total_cost": total_price
                }
                register_tourist(data)

    # Note about children under 5
    st.write("### Note")
    st.info("Children under 5 do not need to be paid for.")

    # Show available packages with habitats and popularity
    st.header("Available Packages")
    for pkg in packages:
        package_habitats = habitat_groups.get(pkg['package_id'], [])
        with st.expander(f"Package: {pkg['package_name']} (${pkg['price']}) - Popularity: {pkg['popularity']} bookings"):
            st.write(f"*Package ID:* {pkg['package_id']}")
            st.write(f"*Habitats Included:* {', '.join(package_habitats) if package_habitats else 'None'}")

    # Show habitats and species
    st.header("Habitats and Associated Species")
    habitat_species = {}
    for entry in species_data:
        habitat_species.setdefault(entry['habitat_name'], []).append(entry['species_name'])

    for habitat, species in habitat_species.items():
        with st.expander(f"Habitat: {habitat}"):
            st.write(f"*Species:* {', '.join(species)}")

if __name__ == "__main__":
    main()
