import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import glm
import os, math
import core/[shader, texture, camera]

var
  window_width: int32 = 1280
  window_height: int32 = 720 

proc main(): void =
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 6)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)
  # glfwWindowHint(GLFWDecorated, GLFW_FALSE) # setWindowAttrib
  # glfwWindowHint(GLFWFloating, GLFW_TRUE) # setWindowAttrib
  # glfwWindowHint(GLFWMouseButtonPassthrough, GLFW_TRUE) # setWindowAttrib

  let window: GLFWWindow = glfwCreateWindow(window_width, window_height, "critic Engine", nil, nil)
  
  window.setInputMode(GLFWCursorSpecial, GLFW_CURSOR_NORMAL)  
  window.makeContextCurrent()

  # additional info
  echo "Vulkan supported: " & $glfwVulkanSupported()
  
  # Opengl
  doAssert glInit()
  echo "OpenGL " & $glVersionMajor & "." & $glVersionMinor

  # additional ImGUI
  let context = igCreateContext()
  doAssert igGlfwInitForOpenGL(window, true)
  doAssert igOpenGL3Init()
  igStyleColorsCherry()

  var vert = @[
    -0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    -0.5f,  0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,

    -0.5f, -0.5f,  0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    -0.5f, -0.5f,  0.5f,

    -0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,

    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,

    -0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f, -0.5f,  0.5f,
    -0.5f, -0.5f,  0.5f,
    -0.5f, -0.5f, -0.5f,

    -0.5f,  0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f, -0.5f 
  ]

  # моделька 
  var VBO, containerVAO: GLuint
  glGenVertexArrays(1, addr containerVAO);
  glGenBuffers(1, addr VBO);
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  # cint(cfloat.sizeof * vert.len)
  glBufferData(GL_ARRAY_BUFFER, cint(GLfloat.sizeof * vert.len), vert[0].addr, GL_STATIC_DRAW);

  glBindVertexArray(containerVAO);
  # Position attribute
  glVertexAttribPointer(0.GLuint, 3, EGL_FLOAT, false, 3 * sizeof(GLfloat), cast[pointer](0));
  glEnableVertexAttribArray(0);
  glBindVertexArray(0);

  # Буферы освещения

  var lightVAO: GLuint
  glGenVertexArrays(1, addr lightVAO)
  glBindVertexArray(lightVAO)
  # Так как VBO объекта-контейнера уже содержит все необходимые данные, то нам нужно только связать с ним новый VAO 
  glBindBuffer(GL_ARRAY_BUFFER, VBO)
  # Настраиваем атрибуты (нашей лампе понадобятся только координаты вершин)
  glVertexAttribPointer(0.Gluint, 3, EGL_FLOAT, false, 3 * sizeof(GLfloat), cast[pointer](0))
  glEnableVertexAttribArray(0);
  glBindVertexArray(0);


  var lightingShader = newShader(getAppDir()/"programs/vertex.glsl", getAppDir()/"programs/fragment.glsl")
  
  var lampShader = newShader(getAppDir()/"programs/vertex.glsl", getAppDir()/"programs/fragment_lamp.glsl")
  
  var lightPos: Vec3[GLfloat] = vec3(1.2f, 1.0f, 2.0f)

  var camera = newCamera(position = vec3(0.0f,0f,3f))
  glClearColor(33f/255, 33f/255, 33f/255, 1f)
  glEnable(GL_DEPTH_TEST)
    
  while not window.windowShouldClose: 
    # Matrixs camera
    var view = camera.getViewMatrix()
    var model = mat4f(1)
    var projection = perspective(camera.zoom, window_width/window_height, 0.1f, 100.0f) 

    if window.getKey(GLFWKey.Left) == GLFW_PRESS:
      camera.position -= camera.right * 0.1
    if window.getKey(GLFWKey.Right) == GLFW_PRESS:
      camera.position += camera.right * 0.1
    if window.getKey(GLFWKey.Up) == GLFW_PRESS:
      camera.position += camera.front * 0.1f
    if window.getKey(GLFWKey.Down) == GLFW_PRESS:
      camera.position -= camera.front * 0.1f

    if window.getKey(GLFWKey.W) == GLFW_PRESS:
      camera.pitch += 0.5f
    if window.getKey(GLFWKey.S) == GLFW_PRESS:
      camera.pitch -= 0.5f
    if window.getKey(GLFWKey.A) == GLFW_PRESS:
      camera.yaw -= 0.5f
    if window.getKey(GLFWKey.D) == GLFW_PRESS:
      camera.yaw += 0.5f

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

    # Кубик
    lightingShader.use() 

    let objectColorLoc = glGetUniformLocation(lightingShader.id, "objectColor")
    let lightColorLoc = glGetUniformLocation(lightingShader.id, "lightColor")
    
    glUniform3f(objectColorLoc, 1.0f, 0.5f, 0.31f)  
    glUniform3f(lightColorLoc, 1.0f, 1.0f, 1.0f)      

    var modelLoc = glGetUniformLocation(lightingShader.id, "model")
    var viewLoc = glGetUniformLocation(lightingShader.id, "view")
    var projLoc = glGetUniformLocation(lightingShader.id, "projection")

    glUniformMatrix4fv(modelLoc, 1.GLsizei, false, addr model[0][0])
    glUniformMatrix4fv(viewLoc, 1.GLsizei, false, addr view[0][0])
    glUniformMatrix4fv(projLoc, 1.GLsizei, false, addr projection[0][0])

       
    glBindVertexArray(containerVAO)    
    model = mat4f(1)
    glUniformMatrix4fv(modelLoc, 1.GLsizei, false, addr model[0][0]);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArray(0)

    # Лампа
    lampShader.use()

    modelLoc = glGetUniformLocation(lampShader.id, "model");
    viewLoc  = glGetUniformLocation(lampShader.id, "view");
    projLoc  = glGetUniformLocation(lampShader.id, "projection");

    glUniformMatrix4fv(viewLoc, 1.GLsizei, false, addr view[0][0])
    glUniformMatrix4fv(projLoc, 1.GLsizei, false, addr projection[0][0])

    model = mat4f(1)
    model = model.translate(lightPos)
    model = model.scale(0.2f)

    glUniformMatrix4fv(modelLoc, 1.GLsizei, false, addr model[0][0])
    glBindVertexArray(lightVAO)
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArray(0);

    window.swapBuffers
    glfwPollEvents()

  window.destroyWindow
  glfwTerminate()
  glDeleteVertexArrays(1, containerVAO.addr)
  glDeleteBuffers(1, VBO.addr)
  glDeleteBuffers(1, lightVAO.addr)

main()