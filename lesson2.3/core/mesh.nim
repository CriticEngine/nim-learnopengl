import nimgl/opengl
import glm
import ../core/shader

type 
    TextureType* = enum
        texture_diffuse,
        texture_specular,
        texture_normal,
        texture_height
    Texture*  = object
        id*: GLuint 
        texType*: TextureType
    Vertex* = object 
        position*: Vec3[GLfloat]
        normal*: Vec3[GLfloat]
        texCoords*: Vec2[GLfloat]
    Mesh* = object
        vertices*: seq[Vertex]       
        indices*: seq[GLuint]
        textures*: seq[Texture] 
        VAO, VBO, EBO: GLuint  
    
proc setupMesh*(mesh: var Mesh): void =
    glGenVertexArrays(1, addr mesh.VAO)
    glGenBuffers(1, addr mesh.VBO)
    glGenBuffers(1, addr mesh.EBO)

    glBindVertexArray(mesh.VAO)
    glBindBuffer(GL_ARRAY_BUFFER, mesh.VBO)

    glBufferData(GL_ARRAY_BUFFER, mesh.vertices.sizeof(), addr mesh.vertices[0], GL_STATIC_DRAW) 

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, mesh.indices.sizeof(), addr mesh.indices[0], GL_STATIC_DRAW)
    # vertex positions
    glEnableVertexAttribArray(0.GLuint)
    glVertexAttribPointer(0.GLuint, 3.GLint, EGL_FLOAT, false, sizeof(Vertex).GLsizei, cast[pointer](0))
    # vertex normals
    glEnableVertexAttribArray(1.GLuint)
    glVertexAttribPointer(1.GLuint, 3.GLint, EGL_FLOAT, false, sizeof(Vertex).GLsizei, cast[pointer](offsetof(Vertex, normal)))
    # vertex texture coords
    glEnableVertexAttribArray(2.GLuint)
    glVertexAttribPointer(2.GLuint, 2.GLint, EGL_FLOAT, false, sizeof(Vertex).GLsizei,  cast[pointer](offsetof(Vertex, texCoords)))
    glBindVertexArray(0)

# , shader: var Shader
proc draw*(mesh: var Mesh): void =

    if mesh.textures.len > 0:
        for textureN in 0..mesh.textures.len-1:    
            glActiveTexture((GL_TEXTURE0.GLuint + textureN.GLuint).GLEnum) #activate proper texture unit before binding
            case (mesh.textures[textureN].texType):
                of texture_diffuse:                     
                    break
                of texture_specular:                    
                    break
                of texture_normal:
                    break
                of texture_height:
                    break
                else:
                    errorMessageWriter("Unknown TextureType." & $mesh.textures[textureN].texType)

            # now set the sampler to the correct texture unit
            #glUniform1i(glGetUniformLocation(shader.ID, (name + number).c_str()), i)                
            glBindTexture(GL_TEXTURE_2D, mesh.textures[textureN].id)

        glActiveTexture(GL_TEXTURE0);
    
    # draw mesh
    glBindVertexArray(mesh.VAO);
    glDrawElements(GL_TRIANGLES, mesh.indices.len.GLsizei, GL_UNSIGNED_INT, cast[pointer](0));
    glBindVertexArray(0);

