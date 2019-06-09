// Code generated by MockGen. DO NOT EDIT.
// Source: finalizer.go

// Package shims_test is a generated GoMock package.
package shims_test

import (
	reflect "reflect"

	gomock "github.com/golang/mock/gomock"
)

// MockDetector is a mock of Detector interface
type MockDetector struct {
	ctrl     *gomock.Controller
	recorder *MockDetectorMockRecorder
}

// MockDetectorMockRecorder is the mock recorder for MockDetector
type MockDetectorMockRecorder struct {
	mock *MockDetector
}

// NewMockDetector creates a new mock instance
func NewMockDetector(ctrl *gomock.Controller) *MockDetector {
	mock := &MockDetector{ctrl: ctrl}
	mock.recorder = &MockDetectorMockRecorder{mock}
	return mock
}

// EXPECT returns an object that allows the caller to indicate expected use
func (m *MockDetector) EXPECT() *MockDetectorMockRecorder {
	return m.recorder
}

// RunLifecycleDetect mocks base method
func (m *MockDetector) RunLifecycleDetect() error {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "RunLifecycleDetect")
	ret0, _ := ret[0].(error)
	return ret0
}

// RunLifecycleDetect indicates an expected call of RunLifecycleDetect
func (mr *MockDetectorMockRecorder) RunLifecycleDetect() *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "RunLifecycleDetect", reflect.TypeOf((*MockDetector)(nil).RunLifecycleDetect))
}