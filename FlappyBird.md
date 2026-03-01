# **Video Game Specification: Native Cross-Platform Swift Game**

## **1\. Architectural Foundations and Frameworks**

This application is a native, cross-platform, 2D side-scrolling physics game targeting macOS, iOS, and iPadOS from a unified codebase.

* **User Interface & State Management:** SwiftUI handles all pre-game states, menus, configuration screens, and overlay statistics.1 State transitions are managed via an application-wide router using an @ObservableObject (or @State) to successfully ingest user selections into the game engine.2  
* **Game Engine:** SpriteKit acts as the core rendering loop and physics simulator, hosted within the SwiftUI hierarchy using a SpriteView.4 It leverages high-speed animation rendering and native collision detection built upon the Metal pipeline.6  
* **Platform Bridging:** The architecture strictly utilizes compiler directives (\#if os(macOS) and \#if os(iOS)) to normalize input handling across operating systems without fracturing the core gameplay loop.8

## **2\. Pre-Game Flow & State Machine**

The application flow relies on a strict data model that dictates transitions across three primary interactive views:

1. **Title State:** The entry point where users select either Single-Player or Two-Player mode.  
2. **Character Selection State:** Allocation of avatars to Player 1 and, conditionally, Player 2\. The roster is dynamically generated using a CaseIterable and Identifiable Swift enum.  
3. **Environment Selection State:** Player 1 dictates the aesthetic and acoustic parameters of the game world, which subsequently configures the active gameplay loop.

## **3\. Entity Design & Playable Roster**

The roster features six distinct playable characters. Because the game utilizes programmatic rendering or scalable system vector graphics (like Apple's SF Symbols) rather than rasterized files, explicit geometric physics bodies must be defined for deterministic collision detection rather than relying on texture-based generation.9

* **Avian (Default)**  
  * *Conceptual Archetype:* Standard biological bird.  
  * *Suggested Visual Implementation:* bird.fill or a yellow circle with a wing attachment.  
  * *Physics Body (SKPhysicsBody) Geometry:* circleOfRadius closely matching visual radius.  
* **Winged Pig**  
  * *Conceptual Archetype:* Comedic and absurdist.11  
  * *Suggested Visual Implementation:* Rounded pink rectangle or modified hare.fill.  
  * *Physics Body (SKPhysicsBody) Geometry:* rectangleOf with rounded corners.  
* **Flying Squirrel**  
  * *Conceptual Archetype:* Natural glider.12  
  * *Suggested Visual Implementation:* Brown horizontal ellipse.  
  * *Physics Body (SKPhysicsBody) Geometry:* rectangleOf mimicking a flattened horizontal profile.  
* **Pegasus**  
  * *Conceptual Archetype:* Mythological construct.12  
  * *Suggested Visual Implementation:* White rectangular body utilizing horse.fill.  
  * *Physics Body (SKPhysicsBody) Geometry:* Complex combination of primary and secondary shapes.  
* **Winged Turtle**  
  * *Conceptual Archetype:* Defies aerodynamics.11  
  * *Suggested Visual Implementation:* Green semi-circle utilizing tortoise.fill.  
  * *Physics Body (SKPhysicsBody) Geometry:* circleOfRadius accommodating a heavy shell.  
* **Bat**  
  * *Conceptual Archetype:* Natural winged mammal.  
  * *Suggested Visual Implementation:* Dark grey triangle or bat.fill.  
  * *Physics Body (SKPhysicsBody) Geometry:* Small circleOfRadius for a highly agile hitbox.

## **4\. Environments & Parallax Rendering**

Player 1 selects the environment, mapping a specific background color, secondary obstacle color, and designated audio file.14

* **Classic**  
  * *Primary Background Color (SKColor):* Light Blue (.cyan)  
  * *Obstacle / Pipe Color:* Bright Green (.green)  
  * *Cognitive and Thematic Implication:* High contrast, quintessential arcade visibility.14  
* **Jungle**  
  * *Primary Background Color (SKColor):* Deep Emerald (.systemGreen)  
  * *Obstacle / Pipe Color:* Brown / Wood (.brown)  
  * *Cognitive and Thematic Implication:* Organic aesthetic, darker outlines for depth.  
* **Underwater**  
  * *Primary Background Color (SKColor):* Deep Navy (.blue)  
  * *Obstacle / Pipe Color:* Coral / Pink (.systemPink)  
  * *Cognitive and Thematic Implication:* Aquatic depths; high saturation contrasts.16  
* **Arctic**  
  * *Primary Background Color (SKColor):* Pale Ice (.white with cyan tint)  
  * *Obstacle / Pipe Color:* Frost Blue (.systemBlue)  
  * *Cognitive and Thematic Implication:* Stark, bright environment.  
* **Desert**  
  * *Primary Background Color (SKColor):* Sand / Ochre (.systemYellow)  
  * *Obstacle / Pipe Color:* Terracotta (.orange)  
  * *Cognitive and Thematic Implication:* Warm palette, sun-bleached atmosphere.  
* **Space**  
  * *Primary Background Color (SKColor):* Pitch Black (.black)  
  * *Obstacle / Pipe Color:* Neon Purple (.purple)  
  * *Cognitive and Thematic Implication:* High contrast void; ideal for starfields.17

**Parallax Background Logic:** The illusion of forward momentum is achieved through an infinite parallax scrolling system.18 The system must instantiate exactly two identical background nodes.20 When a node's maximum X-coordinate falls below the visible viewport boundary, it is mathematically repositioned behind the second node using the following formula:

![][image1]  
This recycling technique prevents catastrophic memory leaks.20

## **5\. Acoustic Architecture**

* **Background Music:** Handled via the AVAudioPlayer class from the AVFoundation framework. This streams compressed audio data asynchronously, allowing for infinite looping (numberOfLoops \= \-1) and continuous streaming without impacting frame rates.23  
* **Sound Effects:** Transient gameplay sounds (flaps, collisions, scoring) utilize SKAction. This pre-loads uncompressed audio samples (.wav or .caf) into the engine and fires them with zero perceptible latency upon input events.23

## **6\. Input Normalization & Event Routing**

Raw user input must be captured natively per platform and normalized for the unified game loop.

**iOS and iPadOS (Capacitive Touch):**

* Input is received via touchesBegan(\_:with:).26 Multi-touch must be enabled at the view level (view.isMultipleTouchEnabled \= true).  
* *1 Player:* Tapping anywhere on the screen triggers the avatar's upward impulse.26  
* *2 Player:* Screen coordinate space is evaluated. touch.location(in: self) extracts the X-coordinate.18 If ![][image2], input routes to Player 1\. If ![][image3], input routes to Player 2\.

**macOS (Keyboard Responder Chain):**

* Input is captured via keyDown(with:) inside the NSResponder.28  
* *1 Player:* The normalized character space (" ") triggers the jump.30  
* *2 Player:* The normalized "a" triggers Player 1; "l" triggers Player 2\.  
* *Strict Normalization:* Keystrokes must be extracted using event.charactersIgnoringModifiers?.lowercased(). This strips Caps Lock and Shift modifiers to prevent input validation failure and unresponsiveness.31

## **7\. Physics Simulation & Core Mechanics**

To prevent frame rate dependence, the simulation relies entirely on SKPhysicsWorld and SKPhysicsBody.32 Display refreshes (e.g., 60 Hz vs. 120 Hz ProMotion) will not alter the gameplay speed.5

**The Deterministic "Flappy" Mechanic:** A constant downward force (gravity, ![][image4]) applies globally. When a player inputs a jump command, their vertical velocity (![][image5]) must be explicitly reset to zero (or a predefined constant jump speed) *before* applying the upward impulse (![][image6]). This neutralizes existing downward momentum and prevents rapid successive inputs from exponentially accumulating kinetic energy.33

**Collision Bitmasks:** The system uses categoryBitMask, contactTestBitMask, and collisionBitMask. The Player avatar explicitly excludes the "ScoreZone" from physical collision rebounding but includes it in the contact test mask to fire the didBegin(\_:) delegate method and increment the score upon successfully clearing an obstacle gap.18

## **8\. Local Multiplayer Split-Screen Architecture**

Two-player simultaneous local multiplayer is achieved via **Single Scene Partitioning**.

* Instead of rendering two costly independent camera nodes, one unified SKScene spans the display. A visual divider demarcates the exact center (frame.midX).18  
* Player 1 is structurally locked to a left X-coordinate (e.g., frame.width \* 0.25); Player 2 is locked to a right X-coordinate (e.g., frame.width \* 0.75).18  
* Obstacles scroll uniformly across the entire screen width, presenting identical topological challenges to both players at slightly offset times.  
* Survival states are independent. If Player 1 contacts an obstacle, their avatar is removed from the physics simulation, but Player 2 remains active until they also fail.18

#### **Works cited**

1. Part 2: Create a multiplayer iOS game: A step by step tutorial \- YouTube, accessed February 28, 2026, [https://www.youtube.com/watch?v=d-5CO\_3pxpQ](https://www.youtube.com/watch?v=d-5CO_3pxpQ)  
2. Sharing data between SwiftUI view and SpriteView scene \- Reddit, accessed February 28, 2026, [https://www.reddit.com/r/SwiftUI/comments/lohguh/sharing\_data\_between\_swiftui\_view\_and\_spriteview/](https://www.reddit.com/r/SwiftUI/comments/lohguh/sharing_data_between_swiftui_view_and_spriteview/)  
3. SwiftUI \- SpriteKit Integration (Passing Data) \- Sprite Kit \- Kodeco Forums, accessed February 28, 2026, [https://forums.kodeco.com/t/swiftui-spritekit-integration-passing-data/134445](https://forums.kodeco.com/t/swiftui-spritekit-integration-passing-data/134445)  
4. Swift for Game Development: A Beginner's Guide \- Commit Studio, accessed February 28, 2026, [https://commitstudiogs.medium.com/swift-for-game-development-a-beginners-guide-16f29f967e18](https://commitstudiogs.medium.com/swift-for-game-development-a-beginners-guide-16f29f967e18)  
5. SpriteKit \- Forums \- Apple Developer, accessed February 28, 2026, [https://developer.apple.com/forums/tags/spritekit](https://developer.apple.com/forums/tags/spritekit)  
6. Get Started \- Games \- Apple Developer, accessed February 28, 2026, [https://developer.apple.com/games/get-started/](https://developer.apple.com/games/get-started/)  
7. SpriteKit is the bomb\! \- Swift \- If Not Nil, accessed February 28, 2026, [https://ifnotnil.com/t/spritekit-is-the-bomb/4441](https://ifnotnil.com/t/spritekit-is-the-bomb/4441)  
8. Load a spritekit scene from another bundle? \- Stack Overflow, accessed February 28, 2026, [https://stackoverflow.com/questions/50729195/load-a-spritekit-scene-from-another-bundle](https://stackoverflow.com/questions/50729195/load-a-spritekit-scene-from-another-bundle)  
9. Released My First iOS Game Using Swift And SpriteKit : r/iOSProgramming \- Reddit, accessed February 28, 2026, [https://www.reddit.com/r/iOSProgramming/comments/199zqoa/released\_my\_first\_ios\_game\_using\_swift\_and/](https://www.reddit.com/r/iOSProgramming/comments/199zqoa/released_my_first_ios_game_using_swift_and/)  
10. Jump height and Gravity not consistent with fluctuating FPS (flappybird-like Javascript minigame) \- Stack Overflow, accessed February 28, 2026, [https://stackoverflow.com/questions/78176820/jump-height-and-gravity-not-consistent-with-fluctuating-fps-flappybird-like-jav](https://stackoverflow.com/questions/78176820/jump-height-and-gravity-not-consistent-with-fluctuating-fps-flappybird-like-jav)  
11. Different Winged Creatures royalty-free images \- Shutterstock, accessed February 28, 2026, [https://www.shutterstock.com/search/different-winged-creatures](https://www.shutterstock.com/search/different-winged-creatures)  
12. What would be some cool animal combinations in a fantasy world? : r/worldbuilding \- Reddit, accessed February 28, 2026, [https://www.reddit.com/r/worldbuilding/comments/11t5klm/what\_would\_be\_some\_cool\_animal\_combinations\_in\_a/](https://www.reddit.com/r/worldbuilding/comments/11t5klm/what_would_be_some_cool_animal_combinations_in_a/)  
13. Need animal themed character ideas : r/Pathfinder\_RPG \- Reddit, accessed February 28, 2026, [https://www.reddit.com/r/Pathfinder\_RPG/comments/13gvnbn/need\_animal\_themed\_character\_ideas/](https://www.reddit.com/r/Pathfinder_RPG/comments/13gvnbn/need_animal_themed_character_ideas/)  
14. A deep-dive into stylized open world game environment creation \- ArtStation, accessed February 28, 2026, [https://www.artstation.com/blogs/anna-lofberg/wBr2A/a-deep-dive-into-stylized-open-world-game-environment-creation](https://www.artstation.com/blogs/anna-lofberg/wBr2A/a-deep-dive-into-stylized-open-world-game-environment-creation)  
15. The Environment art of Alba: a Wildlife Adventure | by ustwo games | Medium, accessed February 28, 2026, [https://medium.com/@ustwogames/the-environment-art-of-alba-a-wildlife-adventure-6bddd8b56955](https://medium.com/@ustwogames/the-environment-art-of-alba-a-wildlife-adventure-6bddd8b56955)  
16. I created a Flappy Bird inspired game, but underwater. What do you think? : r/IndieGaming, accessed February 28, 2026, [https://www.reddit.com/r/IndieGaming/comments/1jjwgtc/i\_created\_a\_flappy\_bird\_inspired\_game\_but/](https://www.reddit.com/r/IndieGaming/comments/1jjwgtc/i_created_a_flappy_bird_inspired_game_but/)  
17. Background animation with depth in SpriteKit \- swift \- Stack Overflow, accessed February 28, 2026, [https://stackoverflow.com/questions/39298383/background-animation-with-depth-in-spritekit](https://stackoverflow.com/questions/39298383/background-animation-with-depth-in-spritekit)  
18. Split Screen 2 Player Local Multiplayer with SpriteKit \- Stack Overflow, accessed February 28, 2026, [https://stackoverflow.com/questions/37865261/split-screen-2-player-local-multiplayer-with-spritekit](https://stackoverflow.com/questions/37865261/split-screen-2-player-local-multiplayer-with-spritekit)  
19. gooddoug/ParallaxScrollingExamples: An example of doing simple parallax scrolling in SpriteKit and Swift \- GitHub, accessed February 28, 2026, [https://github.com/gooddoug/ParallaxScrollingExamples](https://github.com/gooddoug/ParallaxScrollingExamples)  
20. Infinite/Endless Scrolling Background in Swift/SpriteKit | by Itsuki \- Medium, accessed February 28, 2026, [https://medium.com/@itsuki.enjoy/infinite-endless-scrolling-background-in-swift-spritekit-140a723c7d1f](https://medium.com/@itsuki.enjoy/infinite-endless-scrolling-background-in-swift-spritekit-140a723c7d1f)  
21. Parallax Scrolling SpriteKit \- Stack Overflow, accessed February 28, 2026, [https://stackoverflow.com/questions/25699411/parallax-scrolling-spritekit](https://stackoverflow.com/questions/25699411/parallax-scrolling-spritekit)  
22. 6 SpriteKit Background Scrolling Notes \- YouTube, accessed February 28, 2026, [https://www.youtube.com/watch?v=1xgvxvXkPbc](https://www.youtube.com/watch?v=1xgvxvXkPbc)  
23. Swift SpriteKit playing audio in the background \- Stack Overflow, accessed February 28, 2026, [https://stackoverflow.com/questions/28996589/swift-spritekit-playing-audio-in-the-background](https://stackoverflow.com/questions/28996589/swift-spritekit-playing-audio-in-the-background)  
24. How to add Background Music and Sounds in SpriteKit and Swift 4 \- YouTube, accessed February 28, 2026, [https://www.youtube.com/watch?v=HZNa5mT3piY](https://www.youtube.com/watch?v=HZNa5mT3piY)  
25. RainCat: Lesson 5\. How to make a simple SpriteKit game in… | by Marc J Vandehey | Medium, accessed February 28, 2026, [https://medium.com/@marc.vandehey/raincat-lesson-5-23fb12c2f01f](https://medium.com/@marc.vandehey/raincat-lesson-5-23fb12c2f01f)  
26. Handling Touches in a SpriteKit Game \- Check Sim Games, accessed February 28, 2026, [https://checksimgames.com/handling-touches-in-a-spritekit-game/](https://checksimgames.com/handling-touches-in-a-spritekit-game/)  
27. How to implement touch and hold for sprite kit? \- Stack Overflow, accessed February 28, 2026, [https://stackoverflow.com/questions/21717574/how-to-implement-touch-and-hold-for-sprite-kit](https://stackoverflow.com/questions/21717574/how-to-implement-touch-and-hold-for-sprite-kit)  
28. NSEvent | Apple Developer Documentation, accessed February 28, 2026, [https://developer.apple.com/documentation/appkit/nsevent](https://developer.apple.com/documentation/appkit/nsevent)  
29. NSEvent | Apple Developer Documentation, accessed February 28, 2026, [https://developer.apple.com/documentation/appkit/nsevent?language=objc](https://developer.apple.com/documentation/appkit/nsevent?language=objc)  
30. Handling keyboard events in AppKit with Swift \- Stack Overflow, accessed February 28, 2026, [https://stackoverflow.com/questions/24870322/handling-keyboard-events-in-appkit-with-swift](https://stackoverflow.com/questions/24870322/handling-keyboard-events-in-appkit-with-swift)  
31. Handling Keyboard Game Control on macOS \- Indie Gamedev by Johan Steen, accessed February 28, 2026, [https://blog.bitbebop.com/macos-game-keyboard-input/](https://blog.bitbebop.com/macos-game-keyboard-input/)  
32. Swift Spritekit \- William Liu, accessed February 28, 2026, [https://williamqliu.github.io/2020/01/10/swift-spritekit.html](https://williamqliu.github.io/2020/01/10/swift-spritekit.html)  
33. Can someone explain Flappy Bird's physics to me? \[closed\], accessed February 28, 2026, [https://gamedev.stackexchange.com/questions/70268/can-someone-explain-flappy-birds-physics-to-me](https://gamedev.stackexchange.com/questions/70268/can-someone-explain-flappy-birds-physics-to-me)  
34. Make physics change with self.speed in a Flappy Bird style game in SpriteKit?, accessed February 28, 2026, [https://stackoverflow.com/questions/44888272/make-physics-change-with-self-speed-in-a-flappy-bird-style-game-in-spritekit](https://stackoverflow.com/questions/44888272/make-physics-change-with-self-speed-in-a-flappy-bird-style-game-in-spritekit)
