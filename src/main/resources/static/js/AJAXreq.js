document.addEventListener('DOMContentLoaded', function() {
    var selectedDateInput = document.getElementById('selectedDate');
    var apartmentSizeInput = document.getElementById('apartmentSize');
    var timeSlotsContainer = document.getElementById('timeSlots');
    var submitButton = document.getElementById('submitButton');
    var teamsInfoContainer = document.getElementById('teamsInfo');

    // Функция для получения длительности уборки в часах
    function getCleaningDuration() {
        var size = apartmentSizeInput.value;
        var durationMap = {
            '1': 1,   // 1 комната - 1 час
            '2': 1.5, // 2 комнаты - 1.5 часа
            '3': 2,   // 3 комнаты - 2 часа
            '4': 2.5, // 4 комнаты - 2.5 часа
            '5': 3    // 5 комнат - 3 часа
        };
        return durationMap[size] || 1; // по умолчанию 1 час
    }

    // Функция для загрузки доступных временных окон
    function loadTimeWindows() {
        var selectedDate = selectedDateInput.value;
        var apartmentSize = apartmentSizeInput.value;
        teamsInfoContainer.innerHTML = ''; // Очищаем информацию о командах

        if (!selectedDate || !apartmentSize) {
            timeSlotsContainer.innerHTML = '<p>Please select a date and apartment size to view available time slots.</p>';
            return;
        }

        var duration = getCleaningDuration();

        fetch('/product/' + productId + '/available-time-windows?date=' + selectedDate + '&duration=' + duration)
            .then(response => response.json())
            .then(timeWindows => {
                timeSlotsContainer.innerHTML = '';

                if (timeWindows.length === 0) {
                    timeSlotsContainer.innerHTML = '<p>No available time slots for the selected date and apartment size.</p>';
                    return;
                }

                timeWindows.forEach(function(timeWindow) {
                    var timeSlotDiv = document.createElement('div');
                    timeSlotDiv.className = 'time-slot fade-in';

                    var input = document.createElement('input');
                    input.type = 'radio';
                    input.id = 'time_' + timeWindow.replace(/[:\-]/g, '');
                    input.name = 'selectedTimeWindow';
                    input.value = timeWindow;
                    input.required = true;

                    var label = document.createElement('label');
                    label.htmlFor = input.id;
                    label.textContent = timeWindow;

                    // Добавляем обработчик клика для загрузки количества доступных команд
                    input.addEventListener('change', function() {
                        loadAvailableTeams(timeWindow);
                    });

                    timeSlotDiv.appendChild(input);
                    timeSlotDiv.appendChild(label);
                    timeSlotsContainer.appendChild(timeSlotDiv);
                });
            })
            .catch(error => {
                console.error('Error fetching available time windows:', error);
                timeSlotsContainer.innerHTML = '<p>Error loading time slots. Please try again later.</p>';
            });
    }

    // Функция для загрузки доступных команд
    function loadAvailableTeams(timeWindow) {
        var selectedDate = selectedDateInput.value;

        fetch('/product/' + productId + '/available-teams?date=' + selectedDate + '&timeWindow=' + timeWindow)
            .then(response => response.json())
            .then(availableTeams => {
                if (availableTeams > 0) {
                    teamsInfoContainer.innerHTML = 'Available teams: ' + availableTeams;
                } else {
                    teamsInfoContainer.innerHTML = 'No teams available for this time slot.';
                }
            })
            .catch(error => {
                console.error('Error fetching available teams:', error);
            });
    }

    // Функция для обновления стоимости на кнопке отправки
    function updateSubmitButtonCost() {
        var size = apartmentSizeInput.value;
        var cost = 0;

        switch (size) {
            case '1':
                cost = 100;
                break;
            case '2':
                cost = 200;
                break;
            case '3':
                cost = 300;
                break;
            case '4':
                cost = 400;
                break;
            case '5':
                cost = 500;
                break;
            default:
                cost = 0;
        }

        if (cost > 0) {
            submitButton.textContent = 'Submit Request (' + cost + ' zł)';
        } else {
            submitButton.textContent = 'Submit Request';
        }
    }

    selectedDateInput.addEventListener('change', loadTimeWindows);
    apartmentSizeInput.addEventListener('change', function() {
        loadTimeWindows();
        updateSubmitButtonCost();
    });

    // Инициализируем временные слоты, если дата и размер уже выбраны
    if (selectedDateInput.value && apartmentSizeInput.value) {
        loadTimeWindows();
        updateSubmitButtonCost();
    }
});
