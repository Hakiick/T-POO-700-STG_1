# TimeManager

To start the project:

- Run `docker-compose -p time-manager -f docker-compose.yml up`

Now you can visit [`localhost:5173`](http://localhost:5173) from your browser.

## Details

the developement server requires a .env with OVH login for the SMTP server to work

or you can visit the production server where everything should work, at [`time-manager.kwer.fr`](https://time-manager.kwer.fr)

Here's the login for the seeded users general manager :

```
General Manager:
    email: alice@example.com
    password: alice@example.com

Manager:
    email: bob@example.com
    password: bob@example.com

    email: charlie@example.com
    password: charlie@example.com

    email: david@example.com
    password: david@example.com

User:
    email: eve@example.com
    password: eve@example.com
```

---

When creating a user, you need to verify it with link send to your mail box, the link will activate the account and redirect you to the login page without warning, yet.

When creating a user in the admin panel "users" with the "+". you don't have to give a password because the backend will send a password setting mail to the email of the user you created.

A manager can only modify user from its team.

A general manager can create teams and modify any team or user.

the working times that we have seeded are on from the 10/10 to the 31/10
