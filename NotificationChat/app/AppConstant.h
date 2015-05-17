//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		DEFAULT_TAB							0

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		VIDEO_LENGTH						5

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		COLOR_OUTGOING						HEXCOLOR(0x007AFFFF)
#define		COLOR_INCOMING						HEXCOLOR(0xE6E5EAFF)

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		MESSAGE_INVITE						@"Check out PremiumChat. More info: https://relatedcode.com/premium"

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"		//	Class name
#define		PF_INSTALLATION_OBJECTID			@"objectId"				//	String
#define		PF_INSTALLATION_USER				@"user"					//	Pointer to User Class
//-----------------------------------------------------------------------
#define		PF_USER_CLASS_NAME					@"_User"				//	Class name
#define		PF_USER_OBJECTID					@"objectId"				//	String
#define		PF_USER_USERNAME					@"username"				//	String
#define		PF_USER_PASSWORD					@"password"				//	String
#define		PF_USER_EMAIL						@"email"				//	String
#define		PF_USER_EMAILCOPY					@"emailCopy"			//	String
#define		PF_USER_FULLNAME					@"fullname"				//	String
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"		//	String
#define		PF_USER_TWITTERID					@"twitterId"			//	String
#define		PF_USER_FACEBOOKID					@"facebookId"			//	String
#define		PF_USER_PICTURE						@"picture"				//	File
#define		PF_USER_THUMBNAIL					@"thumbnail"			//	File
//-----------------------------------------------------------------------
#define		PF_BLOCKED_CLASS_NAME				@"Blocked"				//	Class name
#define		PF_BLOCKED_USER						@"user"					//	Pointer to User Class
#define		PF_BLOCKED_USER1					@"user1"				//	Pointer to User Class
#define		PF_BLOCKED_USER2					@"user2"				//	Pointer to User Class
#define		PF_BLOCKED_USERID2					@"userId2"				//	String
//-----------------------------------------------------------------------
#define		PF_GROUP_CLASS_NAME					@"Group"				//	Class name
#define		PF_GROUP_USER						@"user"					//	Pointer to User Class
#define		PF_GROUP_NAME						@"name"					//	String
#define		PF_GROUP_MEMBERS					@"members"				//	Array
//-----------------------------------------------------------------------
#define		PF_MESSAGE_CLASS_NAME				@"Message"				//	Class name
#define		PF_MESSAGE_USER						@"user"					//	Pointer to User Class
#define		PF_MESSAGE_GROUPID					@"groupId"				//	String
#define		PF_MESSAGE_TEXT						@"text"					//	String
#define		PF_MESSAGE_PICTURE					@"picture"				//	File
#define		PF_MESSAGE_VIDEO					@"video"				//	File
#define		PF_MESSAGE_CREATEDAT				@"createdAt"			//	Date
//-----------------------------------------------------------------------
#define		PF_PEOPLE_CLASS_NAME				@"People"				//	Class name
#define		PF_PEOPLE_USER1						@"user1"				//	Pointer to User Class
#define		PF_PEOPLE_USER2						@"user2"				//	Pointer to User Class
//-----------------------------------------------------------------------
#define		PF_RECENT_CLASS_NAME				@"Recent"				//	Class name
#define		PF_RECENT_USER						@"user"					//	Pointer to User Class
#define		PF_RECENT_GROUPID					@"groupId"				//	String
#define		PF_RECENT_MEMBERS					@"members"				//	Array
#define		PF_RECENT_DESCRIPTION				@"description"			//	String
#define		PF_RECENT_LASTUSER					@"lastUser"				//	Pointer to User Class
#define		PF_RECENT_LASTMESSAGE				@"lastMessage"			//	String
#define		PF_RECENT_COUNTER					@"counter"				//	Number
#define		PF_RECENT_UPDATEDACTION				@"updatedAction"		//	Date
//-----------------------------------------------------------------------
#define		PF_REPORT_CLASS_NAME				@"Report"				//	Class name
#define		PF_REPORT_USER1						@"user1"				//	Pointer to User Class
#define		PF_REPORT_USER2						@"user2"				//	Pointer to User Class
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"
