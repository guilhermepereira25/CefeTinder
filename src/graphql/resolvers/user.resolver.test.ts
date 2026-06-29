import { UserResolver } from "./user.resolver";

const mockGetUser = jest.fn();

jest.mock("../../grpc/user/user.client", () => ({
  UserServiceClient: jest.fn().mockImplementation(() => ({
    GetUser: mockGetUser,
  })),
}));

function createGrpcUser() {
  return {
    getId: () => "user-1",
    getName: () => "Ana Silva",
    getEmail: () => "ana@cefet.br",
    getAge: () => 22,
    getGender: () => "female",
    getBio: () => "CEFET student",
  };
}

describe("GraphQL UserResolver", () => {
  beforeEach(() => {
    mockGetUser.mockReset();
  });

  it("maps a gRPC user response to the GraphQL user type", async () => {
    mockGetUser.mockResolvedValue(createGrpcUser());

    const resolver = new UserResolver();
    const result = await resolver.getUser("user-1");

    expect(mockGetUser).toHaveBeenCalledWith("user-1");
    expect(result).toMatchObject({
      id: "user-1",
      name: "Ana Silva",
      email: "ana@cefet.br",
      age: 22,
      gender: "female",
      bio: "CEFET student",
    });
    expect(result?.created_at).toBeInstanceOf(Date);
    expect(result?.updated_at).toBeInstanceOf(Date);
  });
});
