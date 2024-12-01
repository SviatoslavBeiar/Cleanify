let map;
let marker;
let geocoder;
let isAddressValid = false; // Flag for address validity

// Function to remove diacritics and convert string to lowercase
function normalizeString(str) {
    return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

function initMap() {
    geocoder = new google.maps.Geocoder();
    map = new google.maps.Map(document.getElementById("map_div"), {
        zoom: 12,
        center: { lat: 52.4084, lng: 16.9342 }, // Center of Poznan
    });
    marker = new google.maps.Marker({
        map: map,
        visible: false, // Marker hidden by default
    });

    // Geocode initial city
    geocodeAddress(initialCity, function(location) {
        if (location) {
            map.setCenter(location);
            marker.setPosition(location);
            marker.setVisible(true);
        }
    });

    // Get input elements and buttons
    const addressInput = document.getElementById("addressInput");
    const findAddressButton = document.getElementById("findAddressButton");
    const submitButton = document.getElementById("submitButton");
    const cityWarning = document.getElementById("cityWarning");

    // Event for pressing Enter in address input field
    addressInput.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault(); // Prevent default Enter behavior
            const address = addressInput.value.trim();
            if (address) {
                geocodeAddress(address);
            }
        }
    });

    // Event for clicking "Find Address" button
    findAddressButton.addEventListener("click", () => {
        const address = addressInput.value.trim();
        if (address) {
            geocodeAddress(address);
        } else {
            alert("Please enter an address.");
        }
    });

    // Event for clicking Submit button
    submitButton.addEventListener("click", (event) => {
        if (!isAddressValid) {
            event.preventDefault(); // Prevent form submission
            alert("Please enter a valid address within " + initialCity + ".");
        }
        // The form is submitted, data is processed on the server
    });
}

// Geocoding function and marker placement
function geocodeAddress(address, callback) {
    geocoder.geocode({ address: address }, (results, status) => {
        if (status === "OK") {
            const location = results[0].geometry.location;
            map.setCenter(location); // Center the map
            marker.setPosition(location); // Set marker
            marker.setVisible(true); // Make marker visible

            // Check if address belongs to specified area
            const addressComponents = results[0].address_components;
            let cityMatch = false;

            addressComponents.forEach(component => {
                if (component.types.includes("locality") || component.types.includes("administrative_area_level_2")) {
                    // Normalize strings for accurate comparison
                    const componentCity = normalizeString(component.long_name);
                    const targetCity = normalizeString(initialCity);
                    if (componentCity === targetCity) {
                        cityMatch = true;
                    }
                }
            });

            if (cityMatch) {
                cityWarning.style.display = "none";
                isAddressValid = true;
                submitButton.disabled = false;
            } else {
                cityWarning.style.display = "block";
                isAddressValid = false;
                submitButton.disabled = true;
            }

            if (callback) callback(location);
        } else {
            alert("Geocode was not successful for the following reason: " + status);
        }
    });
}

// Initialize the map
window.initMap = initMap;
