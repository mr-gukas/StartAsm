#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include <SFML/Graphics/Color.hpp>
#include <SFML/Graphics/Font.hpp>
#include <SFML/Graphics/RectangleShape.hpp>
#include <SFML/Graphics/RenderWindow.hpp>
#include <SFML/System/Clock.hpp>
#include <SFML/System/String.hpp>
#include <string>
#include <cstdlib>
#include <thread>
#include <chrono>

struct crackme_t
{
    sf::RenderWindow    window;
    sf::Texture         texture;
    sf::Sprite          sprite;
    sf::Font            font; 
    sf::Text            beginText;
    sf::RectangleShape  button;
    sf::Text            buttonText;  
    sf::RectangleShape  finish; 
    sf::Text            finishText; 
    sf::RectangleShape  progressBar;
    sf::Music           music;
    sf::View            view;
};

int setText(sf::Text &text, const sf::String &string, const sf::Font &font,
            unsigned int size, int r_clr, int g_clr, int b_clr,
            float x_pos, float y_pos);

int typeWriteEff(std::string &message, sf::Text &text, sf::Clock &clock,
                 unsigned int *charIndex, float *timePerChar);

int setRectangle(sf::RectangleShape &rect, float size_x, float size_y, int r_clr, int g_clr, int b_clr,
                 float thickness, float x_pos, float y_pos);

int buttonPress(sf::Event &event, sf::RectangleShape &button, sf::RenderWindow &window,
                bool *buttonClicked);

int progBar(sf::RectangleShape &progressBar, sf::RenderWindow &window,
            bool *buttonClicked, bool *programFinished);

int setText(sf::Text &text, int r_clr, int g_clr, int b_clr,
            float x_pos, float y_pos);


