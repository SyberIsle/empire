package empire

import (
	"testing"

	"github.com/jinzhu/gorm"
	"github.com/remind101/empire/dbtest"
	"github.com/stretchr/testify/assert"
)

func TestUser_IsValid(t *testing.T) {
	tests := []struct {
		user User
		err  error
	}{
		{User{}, ErrUserName},
		{User{Name: "api"}, nil},
	}

	for _, tt := range tests {
		if err := tt.user.IsValid(); err != tt.err {
			t.Fatalf("%v.IsValid() => %v; want %v", tt.user, err, tt.err)
		}
	}
}

func TestUser_LifeCycle(t *testing.T) {
	db, err := gorm.Open("postgres", dbtest.Open(t))
	if err != nil {
		t.Fatal(err)
	}

	user, err := userFind(&db, "tester")
	assert.Error(t, err)

	assert.NoError(t, userCreate(&db, "tester", "testing"))

	user, err = userFind(&db, "tester")
	assert.NoError(t, err)
	assert.Equal(t, "tester", user.Username)

	assert.NoError(t, userAuth(&db, "tester", "testing"))
	assert.NoError(t, userChangePassword(&db, "tester", "password"))
	assert.NoError(t, userAuth(&db, "tester", "password"))

	user, err = userFind(&db, "tester")
	assert.NoError(t, userDelete(&db, user))

	user, err = userFind(&db, "tester")
	assert.Error(t, err)
	assert.Equal(t, "", user.Username)
}
