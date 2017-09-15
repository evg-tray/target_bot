# Target Bot
## Управление sidekiq:
- `rake sidekiq:start`
- `rake sidekiq:stop`
- `rake sidekiq:restart`
### Sidekiq Web Dashboard:
`rake sidekiq:dash`
### Запуск:
Требуется `Redis`, библиотека `QT` версии 4.8+.

Создать файл `.env` и заполнить по примеру корректным логином, паролем.

`rake sidekiq:start`

`ruby main.rb`
