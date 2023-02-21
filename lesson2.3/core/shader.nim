import os, strutils
import nimgl/opengl
import glm

    
type
    Shader* = object
        id*: GLuint


proc readShader*(filepath: string): cstring  =
    ## Read shader from file with dependencies
    try:        
        var source = splitLines(readFile(filepath))
        let path = splitFile(filepath)

        for line in 0..source.len-1:
            if source[line].find("#include ") != -1:
                let file = source[line].splitWhitespace()
                source[line] = $readShader(path.dir & "/" & file[1])
        return join(source, "\n\r").cstring
    except IOError:
        echo("ERROR LOAD SHADER " & filepath)
    
proc statusShader(shader: GLuint) =
    ## (ECHO ERROR) 
    var status: int32
    glGetShaderiv(shader, GL_COMPILE_STATUS, status.addr);
    if status != GL_TRUE.ord:
        var
            log_length: int32
            message = newSeq[char](1024)
            res: string
        glGetShaderInfoLog(shader, 1024, log_length.addr, message[0].addr);
        for i in message:
            res &= i
        echo res

proc statusProgram(program: GLuint) =
    ## (ECHO ERROR)
    var
        log_length: int32
        message = newSeq[char](1024)
        pLinked: int32
        res: string
    glGetProgramiv(program, GL_LINK_STATUS, pLinked.addr);
    if pLinked != GL_TRUE.ord:
        glGetProgramInfoLog(program, 1024, log_length.addr, message[0].addr);
        for i in message:
            res &= i
        echo res


proc newShader*(vertexPath, fragmentPath: string): Shader =
    try:      
        var     
            vertexCode = readShader(vertexPath)
            fragmentCode = readShader(fragmentPath)

        let vertex = glCreateShader(GL_VERTEX_SHADER)
        glShaderSource(vertex, 1'i32, vertexCode.addr, nil)
        glCompileShader(vertex)
        statusShader(vertex)

        let fragment = glCreateShader(GL_FRAGMENT_SHADER)
        glShaderSource(fragment, 1, fragmentCode.addr, nil)
        glCompileShader(fragment)
        statusShader(fragment)

        let program = glCreateProgram()
        glAttachShader(program, vertex)
        glAttachShader(program, fragment)
        glLinkProgram(program)
        statusProgram(program)

        result.id = program

        glDeleteShader(vertex)
        glDeleteShader(fragment)
    except:
        echo("Shader was not loaded!!!")

proc use*(shader: Shader): void =
    glUseProgram(shader.id)

proc setBool*(shader: Shader, name: string, value: GLboolean): void = 
    glUniform1i(glGetUniformLocation(shader.id, name), value.GLint)

proc setInt*(shader: Shader, name: string, value: GLint): void = 
    glUniform1i(glGetUniformLocation(shader.id, name), value)

proc setFloat*(shader: Shader, name: string, value: GLfloat): void = 
    glUniform1f(glGetUniformLocation(shader.id, name), value)

proc setVec3*(shader: Shader, name: string, value: Vec3[GLfloat]): void =
    glUniform3f(glGetUniformLocation(shader.id, name), value.x, value.y, value.z)