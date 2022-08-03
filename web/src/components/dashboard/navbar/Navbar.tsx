import { Menu, Transition } from "@headlessui/react";
import { SearchIcon } from "@heroicons/react/outline";
import EditPasswordModal from "components/dashboard/EditPasswordModal";
import EditProfile from "components/dashboard/navbar/EditProfile";
import { useModal } from "contexts/ModalContext";
import { useTheme } from "contexts/ThemeContext";
import { useUser } from "contexts/UserContext";
import { Fragment, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import styled from "styled-components";
import classNames from "utils/classNames";
import { getHref } from "utils/get-file-url";
import hexToRgbA from "utils/hexToRgbA";

function NavbarItem({ onClick, text }: { onClick: any; text: string }) {
  return (
    <Menu.Item>
      {({ active }) => (
        <div
          role="button"
          tabIndex={0}
          className={classNames(
            active ? "th-bg-blue th-color-brwhite" : "th-bg-bg th-color-for",
            "block px-5 py-1 text-sm cursor-pointer focus:outline-none"
          )}
          onClick={onClick}
        >
          {text}
        </div>
      )}
    </Menu.Item>
  );
}

const SearchInput = styled.input`
  ::placeholder {
    color: ${(props) => hexToRgbA(props.theme.brightWhite, "0.8")};
  }
`;

export default function Navbar() {
  const { themeColors } = useTheme();
  const [openEditProfile, setOpenEditProfile] = useState(false);
  const { setOpenPreferences } = useModal();
  const { setOpenEditPassword } = useModal();
  const navigate = useNavigate();
  const location = useLocation();
  const profile = location.pathname?.includes("user_profile");

  const { userdata } = useUser();
  const photoURL =
    getHref(userdata?.thumbnailURL) || getHref(userdata?.photoURL);

  return (
    <div
      className={classNames(
        profile ? "col-span-4" : "col-span-3",
        "max-h-12 border-b px-4 th-bg-blue th-border-bg grid grid-cols-6"
      )}
    >
      <div className="col-span-1" />
      <div className="col-span-4 flex items-center justify-center">
        <div
          style={{
            paddingTop: "1px",
            paddingBottom: "1px",
            backgroundColor: hexToRgbA(themeColors?.brightBlue, "0.4")!,
            borderColor: hexToRgbA(themeColors?.selectionBackground, "0.5")!,
          }}
          className="px-3 flex items-center justify-center w-9/12 rounded-md border"
        >
          <SearchIcon
            className="h-4 w-4 mr-2"
            style={{ color: hexToRgbA(themeColors?.brightWhite, "0.8")! }}
          />
          <SearchInput
            theme={themeColors}
            className="w-full bg-transparent th-color-brwhite border-0 focus:outline-none"
            placeholder="Search"
          />
        </div>
      </div>
      <div className="flex items-center justify-end col-span-1">
        <Menu as="div" className="relative">
          {({ open }) => (
            <>
              <div>
                <Menu.Button
                  as="div"
                  className="relative mr-2 cursor-pointer appearance-none"
                >
                  <div className="th-bg-blue rounded-full h-3 w-3 absolute bottom-0 right-0 transform translate-x-1 translate-y-1 flex items-center justify-center">
                    <div
                      style={{
                        backgroundColor: "#94e864",
                      }}
                      className="rounded-full h-2 w-2"
                    />
                  </div>
                  <div
                    className="rounded h-6 w-6 bg-cover"
                    style={{
                      backgroundImage: `url(${
                        photoURL || `${process.env.PUBLIC_URL}/blank_user.png`
                      })`,
                    }}
                  />
                </Menu.Button>
              </div>
              <Transition
                show={open}
                as={Fragment}
                enter="transition ease-out duration-100"
                enterFrom="transform opacity-0 scale-95"
                enterTo="transform opacity-100 scale-100"
                leave="transition ease-in duration-75"
                leaveFrom="transform opacity-100 scale-100"
                leaveTo="transform opacity-0 scale-95"
              >
                <Menu.Items
                  static
                  className="th-bg-bg border th-border-selbg origin-top-right z-10 absolute right-0 mt-2 w-72 rounded-md shadow-xl ring-1 ring-black ring-opacity-5 focus:outline-none py-3"
                >
                  <div className="px-5 flex py-2">
                    <img
                      src={
                        photoURL || `${process.env.PUBLIC_URL}/blank_user.png`
                      }
                      alt="message"
                      className="rounded h-10 w-10"
                    />
                    <div className="flex flex-col px-3">
                      <h5 className="font-bold th-color-for w-48 truncate">
                        {userdata?.displayName || userdata?.fullName}
                      </h5>
                      <div className="flex items-center">
                        <div
                          style={{ backgroundColor: "#007a5a" }}
                          className="rounded-full h-2 w-2 mr-2"
                        />
                        <h6 className="text-sm font-medium capitalize th-color-for">
                          Active
                        </h6>
                      </div>
                    </div>
                  </div>
                  <div className="w-full h-px my-2 th-bg-selbg" />
                  <NavbarItem
                    text="Edit profile"
                    onClick={() => setOpenEditProfile(true)}
                  />
                  <NavbarItem
                    text="Preferences"
                    onClick={() => setOpenPreferences(true)}
                  />
                  <NavbarItem
                    text="Change password"
                    onClick={() => setOpenEditPassword(true)}
                  />
                  <div className="w-full h-px my-2 th-bg-selbg" />
                  <NavbarItem
                    text="Sign out"
                    onClick={() => {
                      navigate("/dashboard/logout");
                    }}
                  />
                </Menu.Items>
              </Transition>
            </>
          )}
        </Menu>
      </div>
      <EditProfile open={openEditProfile} setOpen={setOpenEditProfile} />
      <EditPasswordModal />
    </div>
  );
}
