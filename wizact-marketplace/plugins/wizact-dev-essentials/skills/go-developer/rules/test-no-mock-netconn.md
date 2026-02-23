---
title: Never Mock net.Conn
impact: HIGH
impactDescription: Prevents brittle tests, tests real behavior, catches integration issues
tags: testing, networking, integration-tests, go
category: test
---

## Never Mock net.Conn

Never mock `net.Conn` or low-level network types. Use real connections or test at a higher abstraction level.

**Incorrect (mocking net.Conn):**

```go
// ANTI-PATTERN: Mocking net.Conn
type MockConn struct {
    ReadFunc  func(b []byte) (n int, err error)
    WriteFunc func(b []byte) (n int, err error)
    CloseFunc func() error
    // ... more methods
}

func (m *MockConn) Read(b []byte) (int, error) {
    return m.ReadFunc(b)
}

// Brittle, doesn't test real network behavior
func TestServer(t *testing.T) {
    mockConn := &MockConn{
        ReadFunc: func(b []byte) (int, error) {
            copy(b, []byte("GET / HTTP/1.1\r\n"))
            return 16, nil
        },
    }
    // Tests mock, not real network
}
```

**Correct Option 1: Test at HTTP level (httptest):**

```go
// Test HTTP handlers without mocking network
func TestHTTPHandler(t *testing.T) {
    req := httptest.NewRequest("GET", "/tasks", nil)
    w := httptest.NewRecorder()

    handler := NewTaskHandler(service)
    handler.ServeHTTP(w, req)

    assert.Equal(t, 200, w.Code)
    assert.Contains(t, w.Body.String(), "tasks")
}

// Test HTTP client
func TestHTTPClient(t *testing.T) {
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(200)
        json.NewEncoder(w).Encode(Task{ID: "1"})
    }))
    defer server.Close()

    client := NewTaskClient(server.URL)
    task, err := client.GetTask(context.Background(), "1")

    require.NoError(t, err)
    assert.Equal(t, "1", task.ID)
}
```

**Correct Option 2: Real TCP connections:**

```go
// Use real TCP connections for integration tests
func TestTCPServer(t *testing.T) {
    // Start real listener
    listener, err := net.Listen("tcp", "127.0.0.1:0")
    require.NoError(t, err)
    defer listener.Close()

    // Start server in background
    go func() {
        conn, _ := listener.Accept()
        defer conn.Close()
        // Handle connection
        io.Copy(conn, conn) // Echo server
    }()

    // Connect with real TCP connection
    conn, err := net.Dial("tcp", listener.Addr().String())
    require.NoError(t, err)
    defer conn.Close()

    // Test with real connection
    _, err = conn.Write([]byte("hello"))
    require.NoError(t, err)

    buf := make([]byte, 5)
    _, err = conn.Read(buf)
    require.NoError(t, err)
    assert.Equal(t, "hello", string(buf))
}
```

**Correct Option 3: Test at protocol level:**

```go
// Test custom protocol handler with real connection
func TestProtocolHandler(t *testing.T) {
    // Use net.Pipe for in-process connection
    server, client := net.Pipe()
    defer server.Close()
    defer client.Close()

    // Run handler in background
    go func() {
        handler := NewProtocolHandler()
        handler.Handle(server)
    }()

    // Test from client side with real connection
    _, err := client.Write([]byte("COMMAND\n"))
    require.NoError(t, err)

    buf := make([]byte, 1024)
    n, err := client.Read(buf)
    require.NoError(t, err)
    assert.Equal(t, "OK\n", string(buf[:n]))
}
```

**Correct Option 4: Test at application level:**

```go
// Mock at higher abstraction (repository, not network)
func TestTaskService_FetchRemote(t *testing.T) {
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()

    // Mock the repository interface, not net.Conn
    mockRepo := mocks.NewMockTaskRepository(ctrl)
    mockRepo.EXPECT().
        FetchFromRemote(gomock.Any()).
        Return([]Task{{ID: "1"}}, nil)

    service := NewTaskService(mockRepo)
    tasks, err := service.GetRemoteTasks(context.Background())

    require.NoError(t, err)
    assert.Len(t, tasks, 1)
}
```

**Benefits:**
- Tests real network behavior
- Catches timing, buffering, connection issues
- More robust tests
- Tests actual integration
- Avoids brittle mock implementations

**Use these instead of mocking net.Conn:**
- ✅ `httptest.Server` for HTTP servers
- ✅ `httptest.NewRecorder` for HTTP handlers
- ✅ `net.Pipe()` for in-process connections
- ✅ Real TCP connections on `127.0.0.1:0`
- ✅ Mock at higher abstraction (repository/client interface)

**Applies to**: All network-related testing
