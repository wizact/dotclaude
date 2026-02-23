---
title: Use gomock for Mocking
impact: HIGH
impactDescription: Type-safe mocking, compile-time verification, clear test expectations
tags: testing, mocking, gomock, go
category: test
---

## Use gomock for Mocking

Use gomock for generating type-safe mocks of interfaces. Provides compile-time safety and clear test expectations.

**Setup:**

```bash
go install github.com/golang/mock/mockgen@latest

# Generate mocks
mockgen -source=repository.go -destination=mocks/mock_repository.go -package=mocks
```

**Interface to mock:**

```go
package task

type TaskRepository interface {
    Save(ctx context.Context, task Task) error
    FindByID(ctx context.Context, id string) (Task, error)
    Delete(ctx context.Context, id string) error
}
```

**Incorrect (manual mock implementation):**

```go
// Manual mock - must maintain as interface changes
type MockTaskRepository struct {
    SaveFunc     func(ctx context.Context, task Task) error
    FindByIDFunc func(ctx context.Context, id string) (Task, error)
    DeleteFunc   func(ctx context.Context, id string) error
}

func (m *MockTaskRepository) Save(ctx context.Context, task Task) error {
    if m.SaveFunc != nil {
        return m.SaveFunc(ctx, task)
    }
    return nil
}

// ... repeat for each method
// Error-prone, no compile-time safety
```

**Correct (gomock-generated mock):**

```go
import (
    "testing"
    "github.com/golang/mock/gomock"
    "myapp/mocks"
)

func TestTaskService_Complete(t *testing.T) {
    // Setup
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()

    mockRepo := mocks.NewMockTaskRepository(ctrl)

    // Set expectations
    mockRepo.EXPECT().
        FindByID(gomock.Any(), "task-1").
        Return(Task{ID: "task-1", Done: false}, nil).
        Times(1)

    mockRepo.EXPECT().
        Save(gomock.Any(), gomock.Eq(Task{ID: "task-1", Done: true})).
        Return(nil).
        Times(1)

    // Test
    service := NewTaskService(mockRepo)
    err := service.Complete(context.Background(), "task-1")

    // Verify
    require.NoError(t, err)
    // gomock automatically verifies expectations via ctrl.Finish()
}
```

**Common gomock patterns:**

```go
// Any argument matcher
mockRepo.EXPECT().
    Save(gomock.Any(), gomock.Any()).
    Return(nil)

// Specific value matcher
mockRepo.EXPECT().
    FindByID(gomock.Any(), gomock.Eq("task-1")).
    Return(Task{ID: "task-1"}, nil)

// Custom matcher
mockRepo.EXPECT().
    Save(gomock.Any(), gomock.AssignableToTypeOf(Task{})).
    Return(nil)

// Call count
mockRepo.EXPECT().
    Save(gomock.Any(), gomock.Any()).
    Return(nil).
    Times(3)  // Must be called exactly 3 times

// At least/most
mockRepo.EXPECT().
    FindByID(gomock.Any(), gomock.Any()).
    Return(Task{}, nil).
    MinTimes(1).
    MaxTimes(5)

// Return different values on multiple calls
mockRepo.EXPECT().
    FindByID(gomock.Any(), "task-1").
    Return(Task{}, errors.New("not found")).
    Times(1)

mockRepo.EXPECT().
    FindByID(gomock.Any(), "task-1").
    Return(Task{ID: "task-1"}, nil).
    Times(1)

// Call order matters
gomock.InOrder(
    mockRepo.EXPECT().FindByID(gomock.Any(), "task-1").Return(Task{ID: "task-1"}, nil),
    mockRepo.EXPECT().Save(gomock.Any(), gomock.Any()).Return(nil),
)
```

**Table-driven tests with gomock:**

```go
func TestTaskService_Complete_TableDriven(t *testing.T) {
    tests := []struct {
        name        string
        taskID      string
        setupMock   func(*mocks.MockTaskRepository)
        wantErr     bool
    }{
        {
            name:   "complete pending task successfully",
            taskID: "task-1",
            setupMock: func(m *mocks.MockTaskRepository) {
                m.EXPECT().
                    FindByID(gomock.Any(), "task-1").
                    Return(Task{ID: "task-1", Done: false}, nil)
                m.EXPECT().
                    Save(gomock.Any(), gomock.Any()).
                    Return(nil)
            },
            wantErr: false,
        },
        {
            name:   "error when task not found",
            taskID: "task-99",
            setupMock: func(m *mocks.MockTaskRepository) {
                m.EXPECT().
                    FindByID(gomock.Any(), "task-99").
                    Return(Task{}, errors.New("not found"))
            },
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            ctrl := gomock.NewController(t)
            defer ctrl.Finish()

            mockRepo := mocks.NewMockTaskRepository(ctrl)
            tt.setupMock(mockRepo)

            service := NewTaskService(mockRepo)
            err := service.Complete(context.Background(), tt.taskID)

            if (err != nil) != tt.wantErr {
                t.Errorf("Complete() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

**Benefits:**
- Type-safe (compile-time verification)
- Auto-updates when interface changes
- Clear expectations in tests
- Verifies call count, order, arguments
- Standard tool in Go ecosystem

**When to use:**
- Testing code that depends on interfaces
- Unit testing services with repository dependencies
- Testing error handling paths

**Applies to**: All interface mocking in tests
