#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include <SFML/Graphics/Color.hpp>
#include <SFML/System/Clock.hpp>
#include <string>
#include <cstdlib>
#include <thread>
#include <chrono>

int main()
{
    sf::RenderWindow window(sf::VideoMode(800, 600), "SFML window");

    sf::Texture texture;
    if (!texture.loadFromFile("src/background.jpg")) {
        return 1; 
    }

    sf::Sprite sprite(texture);

    sf::Font font;
    if (!font.loadFromFile("src/font.ttf")) {
        return 1; 
    }
     
    std::string message = "Hello! Let's break someone's life...\n\nAlthough it won't make your life any better...";
    sf::Text text("", font, 30);
    text.setPosition(10.f, 10.f);
    text.setFillColor(sf::Color(0x00, 0xfa, 0x9a));
    text.setOutlineColor(sf::Color(0x00, 0xfa, 0x9a));
    text.setOutlineThickness(1.f);
    
    unsigned int characterIndex = 0;
    sf::Clock clock;
    float timePerCharacter = 0.1f;

    sf::RectangleShape button(sf::Vector2f(800.f, 100.f));
    button.setFillColor(sf::Color(0x00, 0xfa, 0x9a));
    button.setOutlineThickness(2.f);
    button.setOutlineColor(sf::Color::Black);
    button.setPosition(600.f, 150.f);

    sf::RectangleShape progressBar(sf::Vector2f(0.f, 50.f));
    progressBar.setFillColor(sf::Color(0x00, 0xfa, 0x9a));
    progressBar.setOutlineThickness(2.f);
    progressBar.setOutlineColor(sf::Color::Black);  
    progressBar.setPosition(600.f, 300.f);

    sf::Text buttonText("Just click here\n(to ruin a friendship...)", font, 30);
    buttonText.setFillColor(sf::Color::Black);
    buttonText.setPosition(button.getPosition().x + 10.f, button.getPosition().y + 10.f);

    sf::RectangleShape finish(sf::Vector2f(800.f, 100.f));
    finish.setFillColor(sf::Color(0x00, 0xfa, 0x9a));
    finish.setOutlineThickness(2.f);
    finish.setOutlineColor(sf::Color::Black);
    finish.setPosition(600.f, 300.f);

    sf::Text finishText("You got what you wanted.\nBut at what cost...", font, 30);
    finishText.setFillColor(sf::Color::Black);
    finishText.setPosition(finish.getPosition().x + 10.f, finish.getPosition().y + 10.f);

    sf::View view(sf::FloatRect(0.f, 0.f, static_cast<float>(texture.getSize().x), static_cast<float>(texture.getSize().y)));
    view.setViewport(sf::FloatRect(0.f, 0.f, 1.f, 1.f));
    window.setView(view);         
                                 
    sf::Music music;
    if (!music.openFromFile("src/music.ogg")) {
        return 1; 
    }
    music.setLoop(true); 
    music.play(); 
    
    bool buttonClicked   = false;
    bool programFinished = false;

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
            {
                window.close();
            }

            if (event.type == sf::Event::MouseButtonPressed && event.mouseButton.button == sf::Mouse::Left)
            {
                sf::Vector2f mousePos = window.mapPixelToCoords(sf::Vector2i(event.mouseButton.x, event.mouseButton.y));
                if (button.getGlobalBounds().contains(mousePos) && !buttonClicked)
                {
                    buttonClicked  = true;
                    std::thread programThread([](){
                        std::system("../crackme");
                    });
                    programThread.detach();
                }
            }
        }
        
        float deltaTime = clock.restart().asSeconds();

        if (characterIndex < message.size())
        {
            timePerCharacter -= deltaTime;
            if (timePerCharacter <= 0)
            {
                text.setString(text.getString() + message[characterIndex]);
                characterIndex++;

                timePerCharacter = 0.1f;
            }
        }
        
        if (buttonClicked)
        {
            float width = progressBar.getSize().x;
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

            buttonClicked   = false;
            programFinished = true;
            progressBar.setSize(sf::Vector2f(0.f, 10.f));
        }

        window.clear();
        window.draw(sprite);
        window.draw(text);
        window.draw(button);
        window.draw(buttonText);
        if (programFinished)
        {
            window.draw(finish);
            window.draw(finishText);
        }
        window.display();
    }


    return 0;
}

