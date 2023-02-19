import os, strutils
import nimgl/opengl
import glm


type
    Camera* = object
        position*: Vec3[GLfloat]
        front*: Vec3[GLfloat]
        up*: Vec3[GLfloat]
        right*: Vec3[GLfloat]
        worldUp*: Vec3[GLfloat]
        # Eular Angles
        yaw*: GLfloat
        pitch*: GLfloat
        # roll*: GLfloat # чекать
        # Camera options
        # movementSpeed*: GLfloat
        # mouseSensitivity*: GLfloat
        zoom*: GLfloat
proc updateCameraVectors(self: var Camera): void; 
   


proc newCamera*(
    position: Vec3[GLfloat] = vec3(0.0f, 0.0f, 0.0f),
    up: Vec3[GLfloat] = vec3(0.0f, 1.0f, 0.0f), 
    yaw: GLfloat = -90.0f,
    pitch: GLfloat = 0.0f,
    zoom: GLfloat = radians(45.0f)
    ): Camera = 
    ## Constructor with vectors
    result.position = position
    result.position = position
    result.worldUp = up
    result.yaw = yaw
    result.pitch = pitch
    result.zoom = zoom
    result.updateCameraVectors()

proc newCamera*(
    posX, posY, posZ, upX, upY, upZ, yaw, pitch: GLfloat, zoom: GLfloat = radians(45.0f)
    ): Camera = 
    ## Constructor with scalars
    result.position = vec3(posX, posY, posZ)
    result.worldUp = vec3(upX, upY, upZ)
    result.yaw = yaw
    result.pitch = pitch
    result.zoom = zoom
    result.updateCameraVectors()

#proc setDirection(self: var Camera): void = 


proc getViewMatrix*(self: var Camera): Mat4[GLfloat] =
    self.updateCameraVectors()
    return lookAt(self.position, self.position + self.front, self.up)

proc updateCameraVectors(self: var Camera): void =
    var front: Vec3[GLfloat]
    front.x = cos(radians(self.yaw)) * cos(radians(self.pitch))
    front.y = sin(radians(self.pitch))
    front.z = sin(radians(self.yaw)) * cos(radians(self.pitch))
    self.front = normalize(front);
    #Also re-calculate the Right and Up vector
    self.right = normalize(cross(self.front, self.worldUp)) # Normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
    self.up = normalize(cross(self.right, self.front))

