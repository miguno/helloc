/* game.c */

#include "raylib.h"

const Color kLightBlue = {190, 220, 231, 255};
const Color kDarkBlue = {56, 109, 137, 255};
const int kTargetFPS = 60;

int main(void) {
    // Initialization
    const int screen_width = 800;
    const int screen_height = 450;
    InitWindow(screen_width, screen_height, "raylib [core] example - keyboard input");
    SetTargetFPS(kTargetFPS);

    Vector2 ball_position = {(float)screen_width / 2, (float)screen_height / 2};
    const float distance_step = 2.0F;

    // Main game loop
    while (!WindowShouldClose() /* detects the window close button or the ESC key */) {
        // Update
        if (IsKeyDown(KEY_LEFT))
            ball_position.x -= distance_step;
        if (IsKeyDown(KEY_RIGHT))
            ball_position.x += distance_step;
        if (IsKeyDown(KEY_UP))
            ball_position.y -= distance_step;
        if (IsKeyDown(KEY_DOWN))
            ball_position.y += distance_step;

        // Draw
        BeginDrawing();
        ClearBackground(kLightBlue);
        const int text_pos_x = 10;
        const int text_pos_y = 10;
        const int font_size = 20;
        DrawText("Move the ball with arrow keys", text_pos_x, text_pos_y, font_size, DARKGRAY);
        DrawText("Press ESC to quit", text_pos_x, text_pos_y + font_size, font_size, DARKGRAY);
        const float ball_radius = 20.0F;
        DrawCircleV(ball_position, ball_radius, kDarkBlue);
        EndDrawing();
    }

    // De-initialization
    CloseWindow(); // Close window and OpenGL context
    return 0;
}
