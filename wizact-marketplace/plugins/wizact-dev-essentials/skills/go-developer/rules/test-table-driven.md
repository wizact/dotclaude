---
title: Table-Driven Tests
impact: HIGH
impactDescription: Improves test readability, enables descriptive test cases, reduces duplication
tags: testing, table-driven-tests, go
category: test
---

## Table-Driven Tests

Use table-driven tests with descriptive test case names. Preferred pattern for Go testing.

**Incorrect (repetitive test functions):**

```go
func TestCompleteTask_Success(t *testing.T) {
    task := Task{ID: "1", Done: false}
    err := task.Complete()
    if err != nil {
        t.Errorf("expected no error, got %v", err)
    }
}

func TestCompleteTask_AlreadyDone(t *testing.T) {
    task := Task{ID: "2", Done: true}
    err := task.Complete()
    if err == nil {
        t.Error("expected error, got nil")
    }
}

func TestCompleteTask_NoID(t *testing.T) {
    task := Task{ID: "", Done: false}
    err := task.Complete()
    if err == nil {
        t.Error("expected error, got nil")
    }
}
```

**Correct (table-driven with descriptive names):**

```go
func TestTask_Complete(t *testing.T) {
    tests := []struct {
        name    string
        task    Task
        wantErr bool
    }{
        {
            name:    "complete pending task successfully",
            task:    Task{ID: "1", Done: false},
            wantErr: false,
        },
        {
            name:    "error when completing already done task",
            task:    Task{ID: "2", Done: true},
            wantErr: true,
        },
        {
            name:    "error when task has no ID",
            task:    Task{ID: "", Done: false},
            wantErr: true,
        },
        {
            name:    "complete task with description",
            task:    Task{ID: "3", Done: false, Description: "Test task"},
            wantErr: false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := tt.task.Complete()
            if (err != nil) != tt.wantErr {
                t.Errorf("Complete() error = %v, wantErr %v", err, tt.wantErr)
            }
            if !tt.wantErr && !tt.task.Done {
                t.Error("task should be marked as done")
            }
        })
    }
}
```

**Complex assertions:**

```go
func TestTaskService_Create(t *testing.T) {
    tests := []struct {
        name        string
        description string
        repoErr     error
        want        *Task
        wantErr     bool
    }{
        {
            name:        "create task successfully",
            description: "New task",
            repoErr:     nil,
            want:        &Task{Description: "New task", Done: false},
            wantErr:     false,
        },
        {
            name:        "error when description is empty",
            description: "",
            repoErr:     nil,
            want:        nil,
            wantErr:     true,
        },
        {
            name:        "error when repository fails",
            description: "New task",
            repoErr:     errors.New("db error"),
            want:        nil,
            wantErr:     true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockRepo := &MockTaskRepository{err: tt.repoErr}
            service := NewTaskService(mockRepo)

            got, err := service.Create(context.Background(), tt.description)

            if (err != nil) != tt.wantErr {
                t.Errorf("Create() error = %v, wantErr %v", err, tt.wantErr)
                return
            }

            if !tt.wantErr {
                if got.Description != tt.want.Description {
                    t.Errorf("Description = %v, want %v", got.Description, tt.want.Description)
                }
                if got.Done != tt.want.Done {
                    t.Errorf("Done = %v, want %v", got.Done, tt.want.Done)
                }
            }
        })
    }
}
```

**Benefits:**
- Descriptive test case names (shows in output)
- Easy to add new test cases
- Reduces code duplication
- Clear structure for reviewers
- t.Run provides isolated subtests

**When to use:**
- Testing functions with multiple scenarios
- Validating edge cases
- Testing error conditions

**Applies to**: All test scenarios with multiple cases
