<#macro template user>
    <!doctype html>
    <html lang="ru">
    <head>
        <!-- Required meta tags -->
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="stylesheet" href="/static/css/style.css">

        <!-- Bootstrap CSS -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css"
              integrity="sha384-zCbKRCUGaJDkqS1kPbPd7TveP5iyJE0EjAuZQTgFLD2ylzuqKfdKlfG/eSrtxUkn"
              crossorigin="anonymous">

        <title>FindCleaning</title>
        <!-- Custom Styles -->
        <style>
            body {
                background-image: url('https://pennstatehealthnews.org/wp-content/uploads/2019/05/050119-spring-clean.jpg');
                background-size: cover;
                background-position: center;
                background-attachment: fixed;
            }

            /* Стили для боковой панели */
            .side-panel {
                position: fixed;
                top: 0;
                left: -300px; /* Скрыто за левым краем экрана */
                width: 300px;
                height: 100%;
                background-color: #f8f9fa;
                overflow-y: auto;
                box-shadow: 2px 0 5px rgba(0,0,0,0.5);
                transition: left 0.3s ease;
                z-index: 1000;
            }

            .side-panel.show {
                left: 0; /* Панель выезжает на экран */
            }
        </style>
    </head>
    <body>
    <nav class="navbar navbar-dark bg-dark">
        <div class="container-fluid">
            <a href="/" class="navbar-brand mb-0 h1">Cleaning2</a>

            <!-- Кнопка для боковой панели в хедере -->
            <button class="btn btn-outline-light mr-2" onclick="toggleSidePanel()">Toggle Panel</button>

            <#if user.email??>
                <div class="dropdown text-end">
                    <a href="/profile">
                        <img src="/static/images/avatar.png" alt="mdo"
                             width="32" height="32" class="rounded-circle">
                    </a>
                </div>
            <#else>
                <button class="btn btn-light my-2 my-sm-0" type="button"
                        onclick="window.location.href = '/login'">
                    Login
                </button>
            </#if>
        </div>
    </nav>

    <!-- Основной контент страницы -->
    <div class="container-fluid mt-4">
        <div class="row">
            <main class="col-12">
                <#nested/>
            </main>
        </div>
    </div>

    <!-- Боковая панель с информационными блоками -->
    <div class="side-panel" id="sidePanel">
        <!-- Первый блок: Полезная информация -->
        <div class="p-4">
            <h5 class="text-center">Useful Information</h5>
            <ul class="list-unstyled">
                <li><a href="/about" class="text-decoration-none">About Us</a></li>
                <li><a href="/services" class="text-decoration-none">Our Services</a></li>
                <li><a href="/pricing" class="text-decoration-none">Pricing Plans</a></li>
                <li><a href="/faq" class="text-decoration-none">FAQs</a></li>
            </ul>
            <button class="btn btn-primary btn-block mt-3" onclick="window.location.href='/contact'">Contact Us</button>
            <button class="btn btn-outline-secondary btn-block mt-2" onclick="window.location.href='/support'">Customer Support</button>
        </div>

        <!-- Второй блок: Последние новости -->
        <div class="p-4">
            <h5 class="text-center">Latest News</h5>
            <p>Stay updated with the latest news and special offers. Don't miss out on new discounts and service packages!</p>
            <a href="/news" class="btn btn-outline-primary btn-block">Read More</a>
        </div>

        <!-- Третий блок: Быстрые ссылки -->
        <div class="p-4">
            <h5 class="text-center">Quick Links</h5>
            <ul class="list-unstyled">
                <li><a href="/book" class="text-decoration-none">Book a Service</a></li>
                <li><a href="/reviews" class="text-decoration-none">Customer Reviews</a></li>
                <li><a href="/blog" class="text-decoration-none">Cleaning Tips & Blog</a></li>
                <li><a href="/specials" class="text-decoration-none">Special Offers</a></li>
            </ul>
            <button class="btn btn-success btn-block mt-3" onclick="window.location.href='/signup'">Sign Up Now</button>
            <button class="btn btn-outline-warning btn-block mt-2" onclick="window.location.href='/promo'">Promo Codes</button>
        </div>

        <!-- Четвертый блок: Поддержка клиентов -->
        <div class="p-4">
            <h5 class="text-center">Customer Support</h5>
            <p>Need help? Our support team is here 24/7 to assist you with any issues or questions.</p>
            <button class="btn btn-outline-danger btn-block" onclick="window.location.href='/live-chat'">Live Chat</button>
        </div>
    </div>

    <script>
        // Функция для управления боковой панелью
        function toggleSidePanel() {
            const sidePanel = document.getElementById('sidePanel');
            sidePanel.classList.toggle('show');
        }
    </script>

    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"
            integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"
            crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"
            integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"
            crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"
            integrity="sha384-smHYKdLADwkXOn1EmN1qk/HfnUcbVRZyYmZ4qpPea6sjB/pTJ0euyQp0Mk8ck+5T"
            crossorigin="anonymous"></script>
    </body>
    </html>
</#macro>
