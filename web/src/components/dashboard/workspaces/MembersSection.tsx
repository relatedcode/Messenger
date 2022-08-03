import { SearchIcon, TrashIcon, UserAddIcon } from "@heroicons/react/outline";
import Spinner from "components/Spinner";
import { useModal } from "contexts/ModalContext";
import { useUser } from "contexts/UserContext";
import { UsersContext } from "contexts/UsersContext";
import { useWorkspaceById } from "hooks/useWorkspaces";
import { useContext, useMemo, useState } from "react";
import toast from "react-hot-toast";
import { useNavigate, useParams } from "react-router-dom";
import { deleteData } from "utils/api-helpers";
import classNames from "utils/classNames";
import { getHref } from "utils/get-file-url";

function MemberItem({
  id,
  owner,
  member,
}: {
  id: string;
  owner: boolean;
  member: any;
}) {
  const { workspaceId } = useParams();
  const { user } = useUser();
  const navigate = useNavigate();

  const isMe = id === user?.uid;

  const photoURL = getHref(member?.thumbnailURL) || getHref(member?.photoURL);

  const [loading, setLoading] = useState(false);

  const { setOpenWorkspaceSettings } = useModal();

  const deleteMember = async () => {
    setLoading(true);
    try {
      if (isMe) {
        deleteData(`/workspaces/${workspaceId}/members/${id}`);
        setOpenWorkspaceSettings(false);
        navigate("/dashboard");
      } else {
        await deleteData(`/workspaces/${workspaceId}/members/${id}`);
      }
    } catch (err: any) {
      toast.error(err.message);
    }
    setLoading(false);
  };

  return (
    <li className="px-8 py-2 flex justify-between items-center cursor-pointer group">
      <div
        className={classNames(
          owner ? "" : "group-hover:w-5/6",
          "flex items-center w-full"
        )}
      >
        <img
          className="rounded mr-4 h-10 w-10"
          src={photoURL || `${process.env.PUBLIC_URL}/blank_user.png`}
          alt={id}
        />
        <div className="font-bold truncate th-color-for">
          {member?.fullName}
          {isMe && <span className="font-normal ml-1 th-color-for">(me)</span>}
          {owner && (
            <span className="font-normal ml-1 th-color-for"> - owner</span>
          )}
        </div>
      </div>
      {!owner && (
        <div className="opacity-0 group-hover:opacity-100">
          {loading ? (
            <Spinner className="th-color-for" />
          ) : (
            <TrashIcon
              className="h-6 w-6 th-color-red"
              onClick={deleteMember}
            />
          )}
        </div>
      )}
    </li>
  );
}

export default function MembersSection() {
  const { setOpenInviteTeammates } = useModal();
  const { setOpenWorkspaceSettings } = useModal();

  const { workspaceId } = useParams();
  const { value } = useWorkspaceById(workspaceId);

  const [search, setSearch] = useState("");
  const { value: members, loading } = useContext(UsersContext);

  const displayMembers = useMemo(
    () =>
      members.reduce((result: any, member: any) => {
        if (
          member?.fullName?.toLowerCase().includes(search.toLowerCase()) ||
          member?.displayName?.toLowerCase().includes(search.toLowerCase())
        )
          result.push(member);
        return result;
      }, []),
    [members, search]
  );

  if (loading) return null;

  return (
    <>
      <div className="px-8 w-full">
        <div className="flex items-center border w-full shadow-sm rounded px-2 th-color-for th-bg-bg th-border-selbg">
          <SearchIcon className="h-5 w-5 th-color-for" />
          <input
            type="text"
            name="findMembers"
            id="findMembers"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Find members"
            className="block text-base border-0 w-full focus:outline-none focus:ring-0 th-bg-bg"
          />
        </div>
      </div>
      <ul className="w-full mt-6 overflow-y-scroll" style={{ height: "460px" }}>
        <li
          className="px-8 py-2 flex items-center cursor-pointer"
          onClick={() => {
            setOpenWorkspaceSettings(false);
            setOpenInviteTeammates(true);
          }}
        >
          <div className="rounded p-2 mr-4">
            <UserAddIcon className="h-6 w-6 th-color-for" />
          </div>
          <span className="font-bold th-color-for">Invite member</span>
        </li>
        {displayMembers.map((member: any) => (
          <MemberItem
            key={member.objectId}
            id={member.objectId}
            owner={value?.ownerId === member.objectId}
            member={member}
          />
        ))}
      </ul>
    </>
  );
}
