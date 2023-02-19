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

  var
    mesh: tuple[
      vbo,
      vao,
      ebo: uint32
    ]

  var vert = @[
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
     0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,

    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,

    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
     0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,

    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f  
  ]

  var cubePositions: seq[Vec3[GLfloat]] = @[
    vec3( 2.0f,  5.0f, -15.0f), 
    vec3( 0.0f,  0.0f,  0.0f), 
    vec3(-1.5f, -2.2f, -2.5f),  
    vec3(-3.8f, -2.0f, -12.3f),  
    vec3( 2.4f, -0.4f, -3.5f),  
    vec3(-1.7f,  3.0f, -7.5f),  
    vec3( 1.3f, -2.0f, -2.5f),  
    vec3( 1.5f,  2.0f, -2.5f), 
    vec3( 1.5f,  0.2f, -1.5f), 
    vec3(-1.3f,  1.0f, -1.5f) 
  ]
 

#   var cols = @[
#     1f, 1f, 1f,
#     1f, 1f, 1f,
#     1f, 1f, 1f,
#     1f, 1f, 1f
#   ]

  var ind = @[
    0'u32, 1'u32, 3'u32,
    1'u32, 2'u32, 3'u32
  ]


  glGenBuffers(1, mesh.vbo.addr)
  glGenBuffers(1, mesh.ebo.addr)
  glGenVertexArrays(1, mesh.vao.addr)

  glBindVertexArray(mesh.vao)

  glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ebo)

  glBufferData(GL_ARRAY_BUFFER, cint(cfloat.sizeof * vert.len), vert[0].addr, GL_STATIC_DRAW)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, cint(cuint.sizeof * ind.len), ind[
      0].addr, GL_STATIC_DRAW)

  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0.GLuint, 3, EGL_FLOAT, false, sizeof(GLfloat) * 5, cast[pointer](0))

  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1.GLuint, 2, EGL_FLOAT, false, sizeof(GLfloat) * 5, cast[pointer](3 * sizeof(GLfloat)))



  var texture1 = newTexture(getAppDir()/"container.jpg")
  var texture2 = newTexture(getAppDir()/"awesomeface.png")

  var shader = newShader(getAppDir()/"programs/vertex.glsl", getAppDir()/"programs/fragment.glsl")
  shader.use()
  
  # Matrixs

  var camera = newCamera(position = vec3(0.0f,0f,6f),yaw = -90f, pitch = 0f)
  var viewMat = camera.getViewMatrix()

  var modelMat = mat4f(1)
    .rotate(radians(-55.0f), vec3(1.0f, 0.0f, 0.0f))
  
  var projectionMat = perspective(camera.zoom, window_width/window_height, 0.1f, 100.0f)


  let 
    u_ourTexture1 = glGetUniformLocation(shader.id, "ourTexture1")
    u_ourTexture2 = glGetUniformLocation(shader.id, "ourTexture2")
    u_model = glGetUniformLocation(shader.id, "model")
    u_view = glGetUniformLocation(shader.id, "view")
    u_projection = glGetUniformLocation(shader.id, "projection")
  glUniform1i(u_ourTexture1, 1)  
  glUniform1i(u_ourTexture2, 2)   
  glUniformMatrix4fv(u_model, 1.GLsizei, false, addr modelMat[0][0])
  glUniformMatrix4fv(u_view, 1.GLsizei, false, addr viewMat[0][0])
  glUniformMatrix4fv(u_projection, 1.GLsizei, false, addr projectionMat[0][0])

  glClearColor(33f/255, 33f/255, 33f/255, 1f)
  glEnable(GL_DEPTH_TEST)
    
  while not window.windowShouldClose: 
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
    projectionMat = perspective(camera.zoom, window_width/window_height, 0.1f, 100.0f) 
    viewMat = camera.getViewMatrix() 
    

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    texture1.`bind`
    texture2.`bind`
    glUniformMatrix4fv(u_model, 1.GLsizei, false, addr modelMat[0][0])
    glUniformMatrix4fv(u_view, 1.GLsizei, false, addr viewMat[0][0])
    glUniformMatrix4fv(u_projection, 1.GLsizei, false, addr projectionMat[0][0])
    shader.use()

    glBindVertexArray(mesh.vao)
    for i in 0..9:
        var model = mat4f(1)
        .translate(cubePositions[i])
        .rotate(radians(-10.0f*glfwGetTime()), vec3(1.0f, 0.0f, 0.0f))
        var angle: GLfloat = 20.0f * i.GLfloat
        model = rotate(model, radians(angle), vec3(1.0f, 0.3f, 0.5f));
        glUniformMatrix4fv(u_model, 1.GLsizei, false, addr model[0][0]);

        glDrawArrays(GL_TRIANGLES, 0, 36);
        
    glBindVertexArray(0)

    window.swapBuffers
    glfwPollEvents()

  window.destroyWindow
  glfwTerminate()
  glDeleteVertexArrays(1, mesh.vao.addr)
  glDeleteBuffers(1, mesh.vbo.addr)
  glDeleteBuffers(1, mesh.ebo.addr)

main()