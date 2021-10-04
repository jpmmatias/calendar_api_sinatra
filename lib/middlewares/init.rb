require_relative 'jwtauth'
require_relative 'event_exist'
require_relative 'user_allowed_to_see_event'
require_relative 'user_allowed_to_see_invite'
require_relative 'invite_exist'
require_relative 'user_owner_of_the_event'

use JwtAuth
use EventExist
use UserAllowedToSeeEvent
use UserAllowedToSeeInvite
use InviteExist
use UserOwnerOfTheEvent
