#include "raylib.h"

enum { kGameWindowWidth = 800, kGameWindowHeight = 450 };

int main(void) {
  InitWindow(kGameWindowWidth, kGameWindowHeight, "Hello, Game!");

  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawText("Yay! You created your first window!", 190, 200, 20, BLACK);
    EndDrawing();
  }

  CloseWindow();
  return 0;
}
