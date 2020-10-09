package heroku

import (
	"net/http"
	"time"

	"github.com/remind101/empire"
	"github.com/remind101/empire/server/auth"
	"github.com/remind101/pkg/reporter"
)

type User struct {
	// Name is the users username.
	Username  string     `json:"name"`
	CreatedAt *time.Time `json:"created_at"`
	UpdatedAt *time.Time `json:"updated_at"`
}

func newUser(u *empire.DbUser) *User {
	return &User{
		Username:  u.Username,
		CreatedAt: u.CreatedAt,
		UpdatedAt: u.UpdatedAt,
	}
}

func (h *Server) GetUsers(w http.ResponseWriter, r *http.Request) error {
	if h.isValidSession(r) != nil {
		return ErrForbidden
	}

	us, err := h.Users()
	if err != nil {
		return err
	}

	users := make([]*User, len(us))
	for i := 0; i < len(us); i++ {
		users[i] = newUser(us[i])
	}

	w.WriteHeader(200)
	return Encode(w, users)
}

func (h *Server) GetUserInfo(w http.ResponseWriter, r *http.Request) error {
	if h.isValidSession(r) != nil {
		return ErrForbidden
	}

	u, err := h.findUser(r)
	if err != nil {
		return err
	}

	w.WriteHeader(200)
	return Encode(w, newUser(u))
}

// @TODO need to use the ctx like apps so that we know who is doing what
func (h *Server) DeleteUser(w http.ResponseWriter, r *http.Request) error {
	if h.isValidSession(r) != nil {
		return ErrForbidden
	}

	u, err := h.findUser(r)
	if err != nil {
		return err
	}

	if err := h.UserDelete(u.Username); err != nil {
		return err
	}

	return NoContent(w)
}

type PostUserForm struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func (h *Server) PostUser(w http.ResponseWriter, r *http.Request) error {
	var form PostUserForm

	if h.isValidSession(r) != nil {
		return ErrForbidden
	}

	if err := Decode(r, &form); err != nil {
		return err
	}

	h.UserCreate(form.Username, form.Password)

	return NoContent(w)
}

type PatchUserForm struct {
	Password string `json:"password"`
}

func (h *Server) PatchUser(w http.ResponseWriter, r *http.Request) error {
	var form PatchUserForm

	if h.isValidSession(r) != nil {
		return ErrForbidden
	}

	if err := Decode(r, &form); err != nil {
		return err
	}

	u, err := h.findUser(r)
	if err != nil {
		return err
	}

	err = h.UserPassword(u.Username, form.Password)
	if err != nil {
		return err
	}

	return NoContent(w)
}

func (h *Server) isValidSession(r *http.Request) error {
	ctx := r.Context()
	user := auth.UserFromContext(ctx)
	if user.Name == "" {
		return ErrForbidden
	}

	return nil
}

func (h *Server) findUser(r *http.Request) (*empire.DbUser, error) {
	vars := Vars(r)
	username := vars["username"]

	u, err := h.FindUser(username)
	reporter.AddContext(r.Context(), "username", u.Username)

	return u, err
}
