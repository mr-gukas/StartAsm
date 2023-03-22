#include "crack.h"

int crackmeCtor(struct crackme_t *crack)
{
    if (crack == nullptr)
        return 1;
    
    crack->window.create(sf::VideoMode(800, 600), "Crack friend - Lose yourself");

    if (!crack->texture.loadFromFile("../src/background.jpg"))
        return 1;     
    
    crack->sprite.setTexture(crack->texture);
    
    if (!crack->font.loadFromFile("../src/font.ttf"))
        return 1; 
    
    setText(crack->beginText, "", crack->font, 30, 0x00, 0xfa, 0x9a, 10.f, 10.f);
   
    setRectangle(crack->button, 800.f, 100.f, 0x00, 0xfa, 0x9a, 2.f, 600.f, 150.f);

    setRectangle(crack->progressBar, 0.f, 50.f, 0x00, 0xfa, 0x9a, 2.f, 600.f, 300.f);

    setText(crack->buttonText, "Just click here\n(to ruin a friendship...)", crack->font, 30, 
                        0x00, 0x00, 0x00, crack->button.getPosition().x + 10.f, crack->button.getPosition().y + 10.f);

    setRectangle(crack->finish, 800.f, 100.f, 0x00, 0xfa, 0x9a, 2.f, 600.f, 300.f);
     
    setText(crack->finishText, "You got what you wanted.\nBut at what cost...", crack->font, 30, 0x00, 0x00, 0x00, 
            crack->finish.getPosition().x + 10.f, crack->finish.getPosition().y + 10.f);

    crack->view.reset(sf::FloatRect(0.f, 0.f, static_cast<float>(crack->texture.getSize().x), 
                                          static_cast<float>(crack->texture.getSize().y)));

    crack->view.setViewport(sf::FloatRect(0.f, 0.f, 1.f, 1.f));
    crack->window.setView(crack->view);         

    if (!crack->music.openFromFile("../src/music.ogg")) 
        return 1; 

    return 0;
}

int setText(sf::Text &text, const sf::String &string, const sf::Font &font,
            unsigned int size, int r_clr, int g_clr, int b_clr,
            float x_pos, float y_pos)
{
    text.setString(string);
    text.setFont(font);
    text.setCharacterSize(size);
    text.setFillColor(sf::Color(r_clr, g_clr, b_clr));
    text.setPosition(x_pos, y_pos);

    return 0;
}

int progBar(sf::RectangleShape &progressBar, sf::RenderWindow &window,
            bool *buttonClicked, bool *programFinished)
{
    float width    = progressBar.getSize().x;
    float progress = 0.f;

    while (progress < 1.f)
    {
        width += 10.f;
        progress = width / (window.getSize().x - 200.f);
                    progressBar.setSize(sf::Vector2f(width, 10.f));

        window.draw(progressBar);
        window.display();

        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    *buttonClicked   = false;
    *programFinished = true;
    progressBar.setSize(sf::Vector2f(0.f, 10.f));

    return 0;
}


int typeWriteEff(std::string &message, sf::Text &text, sf::Clock &clock,
                 unsigned int *charIndex, float *timePerChar)
{
    float deltaTime = clock.restart().asSeconds();

    if (*charIndex < message.size())
    {
        *timePerChar -= deltaTime;
        if (*timePerChar <= 0)
        {
            text.setString(text.getString() + message[*charIndex]);
            (*charIndex)++;

            *timePerChar = 0.1f;
        }
    }

    return 0;
}

int setRectangle(sf::RectangleShape &rect, float size_x, float size_y, int r_clr, int g_clr, int b_clr,
                 float thickness, float x_pos, float y_pos)
{
    rect.setSize(sf::Vector2f(size_x, size_y));
    rect.setFillColor(sf::Color(r_clr, g_clr, b_clr));
    rect.setOutlineThickness(thickness);
    rect.setOutlineColor(sf::Color::Black);
    rect.setPosition(x_pos, y_pos);

    return 0;
}

int buttonPress(sf::Event &event, sf::RectangleShape &button, sf::RenderWindow &window,
                bool *buttonClicked)
{
    if (event.type == sf::Event::MouseButtonPressed && 
        event.mouseButton.button == sf::Mouse::Left)
    {
        sf::Vector2f mousePos = window.mapPixelToCoords(sf::Vector2i(event.mouseButton.x, event.mouseButton.y));

        if (button.getGlobalBounds().contains(mousePos) && !(*buttonClicked))
        {
            *buttonClicked  = true;
            std::thread programThread([](){
                std::system("../crackme");
            });
            programThread.detach();
        }
    }

    return 0;
}

int main()
{
    crackme_t crack = {};

    crackmeCtor(&crack);

    crack.music.setLoop(true); 
    crack.music.play(); 

    std::string message = "Hello! Let's break someone's life...\n\nAlthough it won't make your life any better...";

    unsigned int characterIndex = 0;
    sf::Clock clock;
    float timePerCharacter = 0.1f;

    bool buttonClicked   = false;
    bool programFinished = false;

    while (crack.window.isOpen())
    {
        sf::Event event;

        while (crack.window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                crack.window.close();
        
            buttonPress(event, crack.button, crack.window, &buttonClicked);
        }

        typeWriteEff(message, crack.beginText, clock, &characterIndex, &timePerCharacter);

        if (buttonClicked)
            progBar(crack.progressBar, crack.window, &buttonClicked, &programFinished);

        crack.window.clear();
        crack.window.draw(crack.sprite);
        crack.window.draw(crack.beginText);
        crack.window.draw(crack.button);
        crack.window.draw(crack.buttonText);

        if (programFinished)
        {
            crack.window.draw(crack.finish);
            crack.window.draw(crack.finishText);
        }

        crack.window.display();
    }

    return 0;
}

