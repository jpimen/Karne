from rest_framework.permissions import BasePermission


class RolePermission(BasePermission):
    allowed_roles = set()
    message = 'You do not have permission to perform this action.'

    def has_permission(self, request, view):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and getattr(user, 'role', None) in self.allowed_roles
        )


class IsCoachOrAdmin(RolePermission):
    allowed_roles = {'coach', 'admin'}
    message = 'Coach or admin role required.'


class IsClient(RolePermission):
    allowed_roles = {'client'}
    message = 'Client role required.'
