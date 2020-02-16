#include "header.hpp"

class Main : public ulm::Program{
    public:
        float time = 0.0f;
        float dt = 0.0f;
        long int numberOfFrames = 0;        

        ulm::Mesh octopus;
        ulm::Camera cam3D;
        ulm::GBuffer gbuffer;
        ulm::Sprite fullscreenSprite;

        ulm::Array<ulm::Skeleton> keyFrames;
        ulm::SkyBox sky;

        float eyeDistance = 0.05;
        bool move = true;

        Main(){
            /* Initialization */

            ulm::Window::setVSync(false);
            ulm::Window::setRelativeMouseMode(move);

            /* Load iqe format and initialize octopus mesh */
            
            ulm::IQE::load(&octopus, &keyFrames, ulm::Properties::getResourcePath("ucubius.iqe")); /* File contains 3 keyframes and one mesh with bone structure*/

            octopus.smoothNormals(glm::radians(50.f));
            octopus.initialize();
            octopus.properties.modelMatrix = glm::rotate(glm::mat4(1.f), glm::radians(-90.f), glm::vec3(1.f, 0.f, 0.f)); //rotate octopus around x axis so he's pointing up

            
            fullscreenSprite = ulm::SpriteFactory::createRectangle(-1.f, -1.f, 2.f, 2.f);

            /* initialize skybox */
            sky.loadFromResources(
                "ft.jpg",
                "bk.jpg",
                "up.jpg",
                "dn.jpg",
                "rt.jpg",
                "lf.jpg");


            cam3D.createPerspective(glm::radians(50.0f), (float)ulm::Window::screenSize.x / (float)ulm::Window::screenSize.y, 0.1f, 500.f);
            gbuffer.initialize(ulm::Window::screenSize);
            cam3D.position = glm::vec3(0.f, 0.f, -2.f);
            

            #ifdef BU_VR
                ulm::CardboardVR::setNearPlane(0.1f);
                ulm::CardboardVR::setFarPlane(500.f);
            #endif
        }


        unsigned long int b = 0;
        unsigned long int c = 40;

        void update(float deltaTime){
            /* Run each frame */
            b++;
            numberOfFrames++;
            time += deltaTime;
            dt = deltaTime;

            /* Interpolate keyFrames for current frame */

            if(b % (3 * c) < c)
                octopus.properties.skeleton = ulm::Skeleton::interpolation(keyFrames[2], keyFrames[1], (float)(b % c) / (float)c);
            else if(b % (3 * c) < 2 * c)
                octopus.properties.skeleton = ulm::Skeleton::interpolation(keyFrames[1], keyFrames[0], (float)(b % c) / (float)c);
            else
                octopus.properties.skeleton = ulm::Skeleton::interpolation(keyFrames[0], keyFrames[2], (float)(b % c) / (float)c);
            

            /* Handle input */
            
            if(ulm::Window::keysDown[ulm::SCANCODE_ESCAPE]){
                move = !move;
                ulm::Window::setRelativeMouseMode(move);
            }

            float viewSpeed = 3.f * deltaTime;

            if(ulm::Window::keysPressed[ulm::SCANCODE_LEFT])    cam3D.yaw(      viewSpeed);
            if(ulm::Window::keysPressed[ulm::SCANCODE_RIGHT])   cam3D.yaw(     -viewSpeed);
            if(ulm::Window::keysPressed[ulm::SCANCODE_UP])      cam3D.pitch(    viewSpeed);
            if(ulm::Window::keysPressed[ulm::SCANCODE_DOWN])    cam3D.pitch(   -viewSpeed);

            if(move){
                cam3D.yaw(  -(float)ulm::Window::mouse.dx  * 0.005f);
                cam3D.pitch(-(float)ulm::Window::mouse.dy  * 0.005f);
            }

            float speed = 4.8f * deltaTime;

            if(ulm::Window::keysPressed[ulm::SCANCODE_A])       cam3D.right(    -speed);
            if(ulm::Window::keysPressed[ulm::SCANCODE_D])       cam3D.right(     speed);
            if(ulm::Window::keysPressed[ulm::SCANCODE_W])       cam3D.forward(   speed);
            if(ulm::Window::keysPressed[ulm::SCANCODE_S])       cam3D.forward(  -speed);
            if(ulm::Window::keysPressed[ulm::SCANCODE_RSHIFT])  cam3D.higher(   -speed);
            if(ulm::Window::keysPressed[ulm::SCANCODE_SPACE])   cam3D.higher(    speed);//*/

            if(ulm::Window::controllerExists()){
                if(abs(ulm::Window::getFirstPluggedController().lY) > 0.1f) cam3D.forward(ulm::Window::getFirstPluggedController().lY * speed);
                if(abs(ulm::Window::getFirstPluggedController().lX) > 0.1f) cam3D.right(ulm::Window::getFirstPluggedController().lX * speed);

                cam3D.yaw(-ulm::Window::getFirstPluggedController().rX * viewSpeed);
                cam3D.pitch(-ulm::Window::getFirstPluggedController().rY * viewSpeed);
            }
        }

        void render(ulm::Eye eye){
            /* Render frame */

            /* 3D */
            #ifdef BU_VR
                /* Handle VR */
                cam3D.projection =    ulm::CardboardVR::getPerspective();
                cam3D.up =            ulm::CardboardVR::getUp();
                cam3D.front =         ulm::CardboardVR::getFront();
                cam3D.position +=     (float)(eye) * ulm::CardboardVR::getRight() * eyeDistance;
            #endif

            ulm::Window::getGLError(true);
            gbuffer.clear();
            
            /* Update geometry buffer */
            ulm::Renderer3D::begin(cam3D, &gbuffer);
            ulm::Renderer3D::submit(octopus, ulm::Animated);
            ulm::Renderer3D::draw(ulm::CullBackFace);

            /* Handle lights */
            ulm::LightManager::begin(cam3D, &gbuffer);
            ulm::LightManager::submit(ulm::DirectionalLight(glm::vec3(1.f, -1.f, 1.f), glm::vec3(1.f), 0.f));
            ulm::LightManager::draw();

            /* Draw sky to the output of geometry buffer */
            ulm::SkyBoxRenderer::drawSkyBox(sky, &gbuffer, cam3D);

            fullscreenSprite.texture = gbuffer.getResult();

            /* Draw the result from gbuffer to screen */
            ulm::Renderer2D::begin(glm::mat4(1.f));
            ulm::Renderer2D::draw(fullscreenSprite, ulm::Textured | ulm::Multiplied);
            ulm::Renderer2D::end();


            /* GUI */

            ulm::NK::processInput(ulm::Window::mouse, ulm::Window::wheel,
                                  ulm::Window::keysPressed, ulm::Window::keysDown, ulm::Window::keysUp, 
                                  ulm::Window::textInput);

            if (nk_begin(ulm::NK::ctx, "Demo", nk_rect(20, 20, 300, 200),
                NK_WINDOW_BORDER|NK_WINDOW_MOVABLE|NK_WINDOW_SCALABLE|
                NK_WINDOW_CLOSABLE|NK_WINDOW_MINIMIZABLE|NK_WINDOW_TITLE))
            {
                nk_layout_row_dynamic(ulm::NK::ctx, 20, 1); 
                nk_label_wrap(ulm::NK::ctx, (ulm::String("current dt: ") + dt + " ms").getPtr());

                nk_layout_row_dynamic(ulm::NK::ctx, 20, 1); 
                nk_label_wrap(ulm::NK::ctx, (ulm::String("average dt: ") + (time / (float)numberOfFrames) + " ms").getPtr());
                nk_layout_row_dynamic(ulm::NK::ctx, 20, 1); 
                nk_label_wrap(ulm::NK::ctx, (ulm::String("average framerate: ") + ((float)numberOfFrames / time) + " fps").getPtr());
            }

            nk_end(ulm::NK::ctx);
            ulm::NK::draw();

            #ifdef BU_VR
                /* Handle VR */
                cam3D.position -= (float)eye * ulm::CardboardVR::getRight() * eyeDistance;
            #endif 
        }

        void resizeCallback(int width, int height){
            /* When resize */
            ulm::NK::setSize(width, height);
            cam3D.createPerspective(glm::radians(50.0f), (float)width / (float)height, 0.1f, 500.f);
            gbuffer.initialize(width, height);
        }

        ~Main(){
            /* Destruction */
        }
};

ulm::Program * ulm::Properties::onStart(){
    ulm::Window::initialize(BU_APP_NAME, 256, 256);
    ulm::Window::maximize(true);
    return new Main();
}

void ulm::Properties::handleError(ulm::String error){
    printf("\n%s\n", error.getPtr());
    fflush(stdout);
}