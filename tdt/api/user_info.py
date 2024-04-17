import subprocess


def get_user_info():
    """
    Get the user name and email from git config.
    :return: user name and email
    """
    user_name = subprocess.check_output(["git", "config", "user.name"]).strip().decode()
    user_email = (
        subprocess.check_output(["git", "config", "user.email"]).strip().decode()
    )
    return {"user_name": user_name, "user_email": user_email}
