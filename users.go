package empire

import (
	"github.com/jinzhu/gorm"
	"golang.org/x/crypto/bcrypt"
	"time"

	"github.com/remind101/empire/pkg/timex"
)

// User represents a user of Empire.
type User struct {
	// Name is the users username.
	Name string `json:"name"`

	// GitHubToken is a GitHub access token.
	GitHubToken string `json:"-"`
}

type dbUser struct {
	// A unique uuid that identifies the application
	ID string

	// The name of the user
	Username string

	// The users password
	Password string

	// The time that this user was created
	CreatedAt *time.Time

	// The time that this user was created
	UpdatedAt *time.Time

	// If this is non-nil, the user was deleted at this time
	DeletedAt *time.Time
}

// IsValid returns nil if the User is valid.
func (u *User) IsValid() error {
	if u.Name == "" {
		return ErrUserName
	}

	return nil
}

// IsValid returns nil if the User is valid.
func (u *dbUser) isValid() error {
	if u.Username == "" {
		return ErrUserName
	}

	return nil
}

func userFind(db *gorm.DB, username string) (*dbUser, error) {
	var user dbUser

	return &user, db.First(&user, "username = ? and deleted_at IS NULL", &username).Error
}

// userAuth authenticates a user against the database and returns the User
func userAuth(db *gorm.DB, username string, password string) error {
	user, err := userFind(db, username)
	if err != nil && err == gorm.RecordNotFound {
		return ErrUserNotFound
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password))
	if err != nil && err == bcrypt.ErrMismatchedHashAndPassword {
		//Password does not match!
		return ErrPasswordInvalid
	}

	return nil
}

func (u *dbUser) TableName() string {
	return "users"
}

//func (u *dbUser) BeforeSave() error {
//	t := timex.Now()
//	if u.CreatedAt == nil {
//		u.CreatedAt = &t
//	} else {
//		u.UpdatedAt = &t
//	}
//
//	fmt.Printf("==\n%v\n==\n", u)
//
//	return u.isValid()
//}

func (u *dbUser) BeforeCreate() error {
	t := timex.Now()
	u.CreatedAt = &t

	return u.isValid()
}

func (u *dbUser) BeforeUpdate() error {
	t := timex.Now()
	u.UpdatedAt = &t

	return u.isValid()
}

// userUpdate updates the user
func userUpdate(db *gorm.DB, user *dbUser) error {
	return db.Save(&user).Error
}

// userCreate creates the user
func userCreate(db *gorm.DB, username string, password string) error {
	user, err := userFind(db, username)
	if err == nil {
		return ErrUserExists
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		// problem creating the hashed password
		return ErrUserPassword
	}

	user = &dbUser{
		Username: username,
		Password: string(hashedPassword),
	}

	return db.Create(user).Error
}

// userChangePassword changes the password
func userChangePassword(db *gorm.DB, username string, password string) error {
	user, err := userFind(db, username)
	if err != nil && err == gorm.RecordNotFound {
		return ErrUserNotFound
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		// problem creating the hashed password
		return ErrUserPassword
	}

	user.Password = string(hashedPassword)

	return userUpdate(db, user)
}

func userDelete(db *gorm.DB, user *dbUser) error {
	t := timex.Now()
	user.DeletedAt = &t

	return userUpdate(db, user)
}
